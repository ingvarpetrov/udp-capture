#!/bin/bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

BOX_TOP="+------------------------------------------------------+"
BOX_BOTTOM="+------------------------------------------------------+"
BOX_SEP="|------------------------------------------------------|"


echo -e "${CYAN}[DEBUG] capture.sh started at $(date)${RESET}" >&2
CONFIG_FILE="/app/capture.cfg"

# Parse config
output_folder="./output"
parallel_streams=4
segment_length_seconds=3600
total_segments=24
udp_streams=()
interface_ip=""

parse_config() {
    local in_streams=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^output_folder= ]]; then
            output_folder="${line#output_folder=}"
        elif [[ "$line" =~ ^parallel_streams= ]]; then
            parallel_streams="${line#parallel_streams=}"
        elif [[ "$line" =~ ^segment_length_seconds= ]]; then
            segment_length_seconds="${line#segment_length_seconds=}"
        elif [[ "$line" =~ ^total_segments= ]]; then
            total_segments="${line#total_segments=}"
        elif [[ "$line" =~ ^interface_ip= ]]; then
            interface_ip="${line#interface_ip=}"
        elif [[ "$line" == "udp_streams:" ]]; then
            in_streams=1
        elif [[ $in_streams -eq 1 && -n "$line" ]]; then
            udp_streams+=("$line")
        fi
    done < "$CONFIG_FILE"
    echo -e "${CYAN}[DEBUG] Parsed config: output_folder=$output_folder, parallel_streams=$parallel_streams, segment_length_seconds=$segment_length_seconds, total_segments=$total_segments, interface_ip=$interface_ip, udp_streams=(${udp_streams[*]})${RESET}" >&2
}

show_instructions() {
    echo   "$BOX_TOP"
    echo   "|                Mass Capture Session                  |"
    echo   "$BOX_BOTTOM"
    echo   "| [Instructions]                                       |"
    echo   "|  • Stop:      Ctrl-b x (kills capture, all files     |"
    echo   "|                will be finalized)                    |"
    echo   "|  • Detach:    Ctrl-b d (capture continues running    |"
    echo   "|                in the background)                    |"
    echo   "|  • Restart:   exit and run ./run.sh                  |"
    echo   "$BOX_SEP"
}

# Track per-stream segment completion
stream_segments=()

show_progress() {
    echo -e "${CYAN}[Current Streams Capturing]${RESET}"
    for idx in "${!active_streams[@]}"; do
        stream_num=$((idx+1))
        # Find all segment files for this stream and sum their sizes
        pattern="$output_folder/stream$(printf '%02d' $stream_num)_seg*.ts"
        size=0
        if compgen -G "$pattern" > /dev/null; then
            size=$(du -ch $pattern 2>/dev/null | grep total | awk '{print $1}')
        else
            size="0"
        fi
        printf "  %2d. %-20s  [Segments: %d/%d, Size: %s]\n" $((idx+1)) "${active_streams[$idx]}" "${stream_segments[$idx]}" "$total_segments" "$size"
    done
    echo -e "\n${MAGENTA}[Progress]${RESET}"
    printf "  Segment:        %s / %s\n" "$current_segment" "$total_segments"
    # Progress bar for current segment
    local percent=$(( 100 * elapsed / segment_length_seconds ))
    local bar_length=20
    local filled=$(( bar_length * percent / 100 ))
    local empty=$(( bar_length - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="#"; done
    for ((i=0; i<empty; i++)); do bar+="-"; done
    local mins=$(( (segment_length_seconds - elapsed) / 60 ))
    local secs=$(( (segment_length_seconds - elapsed) % 60 ))
    printf "  Time left:      %2dm %02ds [${GREEN}%s${RESET}] %d%%\n" "$mins" "$secs" "$bar" "$percent"
    # Overall progress
    local total_segments_all=$((total_streams * total_segments))
    local completed=0
    for seg in "${stream_segments[@]}"; do
        completed=$((completed + seg))
    done
    local overall_percent=$(( 100 * completed / total_segments_all ))
    local overall_filled=$(( bar_length * overall_percent / 100 ))
    local overall_empty=$(( bar_length - overall_filled ))
    local overall_bar=""
    for ((i=0; i<overall_filled; i++)); do overall_bar+="#"; done
    for ((i=0; i<overall_empty; i++)); do overall_bar+="-"; done
    printf "  Overall:        [%s] %d%% (%d/%d segments complete)\n" "$overall_bar" "$overall_percent" "$completed" "$total_segments_all"
    # Disk space
    local diskline=$(df -h "$output_folder" | tail -1)
    local avail=$(echo "$diskline" | awk '{print $4}')
    local mount=$(echo "$diskline" | awk '{print $6}')
    printf "  Disk space:     %s free (mounted on %s)\n" "$avail" "$mount"
    echo -e "${BLUE}${BOX_SEP}${RESET}"
}

main() {
    parse_config
    mkdir -p "$output_folder"
    total_streams=${#udp_streams[@]}
    current_segment=1
    # Initialize per-stream segment counters
    for ((i=0; i<$total_streams; i++)); do
        stream_segments[$i]=0
    done

    while [[ $current_segment -le $total_segments ]]; do
        echo "Starting segment $current_segment/$total_segments..."
        active_streams=()
        pids=()
        idxs=()
        for ((i=0; i<$total_streams && i<$parallel_streams; i++)); do
            stream="${udp_streams[$i]}"
            # Ensure stream is prefixed with udp://
            if [[ "$stream" != udp://* ]]; then
                stream="udp://$stream"
            fi
            out_file="$output_folder/stream$(printf '%02d' $((i+1)))_seg$(printf '%02d' $current_segment).ts"
            pu_cmd=(/usr/local/bin/__pu "$stream")
            if [[ -n "$interface_ip" ]]; then
                pu_cmd+=(-ii "$interface_ip")
            fi
            pu_cmd+=(-o "$out_file" -t "$segment_length_seconds")
            echo -e "${YELLOW}[DEBUG] Launching: ${pu_cmd[*]}${RESET}" >&2
            "${pu_cmd[@]}" >/dev/null 2>&1 &
            pids+=("$!")
            active_streams+=("$stream")
            idxs+=("$i")
        done
        start_time=$(date +%s)
        while :; do
            elapsed=$(( $(date +%s) - start_time ))
            clear
            show_instructions
            show_progress
            if [[ $elapsed -ge $segment_length_seconds ]]; then
                break
            fi
            sleep 10
        done
        # Update per-stream segment counters
        for idx in "${idxs[@]}"; do
            stream_segments[$idx]=$(( ${stream_segments[$idx]} + 1 ))
        done
        current_segment=$((current_segment+1))
    done
    echo -e "${GREEN}Capture complete.${RESET}"
}

main 