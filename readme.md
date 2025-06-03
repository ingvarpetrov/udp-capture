# Mass Capture System

## Quick Start (Ubuntu, Docker required)

You can install and set up everything in one step (no git required):

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/ingvarpetrov/udp-capture/main/quickstart.sh)
```

- This will download the project, build the Docker image, and print next steps.
- **Note:** This script is for Ubuntu systems and assumes Docker is already installed.

## Screenshot

<img src="src/capture-screenshot.png" alt="Capture Session Screenshot" width="400"/>

## Output Folder

- The `output` directory is mounted as a Docker volume at `/output` inside the container.
- **The output folder is cleared (all files deleted) every time you run `./run.sh`.**
- All captured files will appear in your local `output/` folder and will be owned by your user (using Docker's `-u` flag).

## Configuration
Edit `capture.cfg` to set your parameters:

```
output_folder=/output
parallel_streams=4
segment_length_hours=1
total_segments=24
# Optional: set the IP address of the interface to use for multicast capture
# interface_ip=192.168.1.100

udp_streams:
239.0.0.1:1234
239.0.0.2:1234
239.0.0.3:1234
239.0.0.4:1234
239.0.0.5:1234
```

- `output_folder`: Should be `/output` to match the Docker mount.
- `parallel_streams`: How many streams to capture at once
- `segment_length_hours`: Length of each segment in hours
- `total_segments`: How many segments to capture
- `interface_ip`: (Optional) IP address of the interface to use for multicast capture
- `udp_streams`: List of UDP streams, one per line after `udp_streams:`

## Build and Run

1. **Build the Docker image:**
   ```
   ./install.sh
   ```
2. **Start the capture process (container and tmux session):**
   ```
   ./run.sh
   ```
   - This will clear the output folder, remove any old container, start a new one, and launch the capture script in a tmux session inside the container.

3. **Monitor the capture session in tmux:**
   ```
   ./monitor.sh
   ```
   - This will attach to the tmux session inside the running container for live monitoring.

## Tmux Interface
- **Stop:** `ctrl-b x` (kills capture, all files will be finalized)
- **Detach:** `ctrl-b d` (capture continues running in the background)
- **Restart:** Exit and run `./run.sh` again
- The tmux pane will show:
  - Instructions (including what stop/detach do)
  - Which channels are being captured
  - Time left for current segment
  - Disk space left
  - Per-stream and overall progress
  - **Per-stream segment sizes so far**

## Notes
- All files (output, config, scripts) are mounted as volumes and owned by the host user (using Docker's `-u` flag; no entrypoint user logic).
- The output folder is cleared on each run.
- Uses an older, stable version of tsduck for compatibility.
- Everything is configurable via `capture.cfg`.

## Testing a UDP Stream

You can use the provided `test.sh` script to check if a UDP stream is reachable and can be captured:

```
./test.sh 239.0.0.1:1234
```

This will attempt to capture a short sample and report success or failure. The script uses Docker and will clean up the test file automatically.

## Troubleshooting

### Multicast Routing
If you cannot receive multicast traffic, you may need to add a multicast route. For example:

```
sudo route add -net 224.0.0.0 netmask 240.0.0.0 eth0
```
Replace `eth0` with the correct interface name.

### Disabling Reverse Path Filtering (rp_filter)
Reverse path filtering can block multicast. To disable it:

```
sudo sysctl -w net.ipv4.conf.all.rp_filter=0
sudo sysctl -w net.ipv4.conf.default.rp_filter=0
sudo sysctl -w net.ipv4.conf.eth0.rp_filter=0
```
Replace `eth0` with your interface if needed.

### General Tips
- Ensure your Docker container is running with `--network host` and `--privileged`.
- Check that your interface is up and has the correct IP address.
- Use `./test.sh` to verify stream reachability before starting a full capture.

## Docker Installation (Ubuntu)

If you do not have Docker installed, follow these steps:

**Set up Docker's apt repository:**
```sh
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

**Install Docker:**
```sh
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Verify Docker installation:**
```sh
sudo docker run hello-world
```

**(Optional) Add your user to the docker group:**
```sh
sudo usermod -aG docker $USER
```
Log out and log back in for group changes to take effect. 