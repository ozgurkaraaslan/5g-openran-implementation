# 5g-openran-implementation

This project integrates O-RAN SC components, the Colosseum Near-RT RIC platform, and ns-3 mmWave simulation into a single **Docker-in-Docker (DinD)** environment.

The system consists of 3 main components managed via 3 separate terminal sessions:

1. **Near-RT RIC (E2Term):** Manages E2 connections.
2. **xApp:** Sample logic application running on the RIC.
3. **ns-3 Simulation:** Simulates the RAN and sends data via the E2 interface.

---

## 1. Setup and Environment Preparation

First, build the main Docker image and start the container in **Privileged** mode.

```bash
# Build the image
sudo docker build -t e2sim-dind .

# Run the container and enter the shell
sudo docker run --privileged -it e2sim-dind bash

Once inside the container, start the Docker Daemon manually:
# Start Docker daemon in the background
dockerd > /var/log/dockerd.log 2>&1 &

# Wait a few seconds for it to initialize
sleep 5
```

## 2. Simulation Steps

You will need 3 separate terminal windows to run the simulation. (Tip: To open a new terminal in the running container from your host, use: docker exec -it <container_id> bash)

Terminal 1: Near-RT RIC Setup (Controller)
In this terminal, we set up the RIC platform and monitor the E2 Termination point.

### Clone the RIC repository

```bash
git clone -b ns-o-ran [https://github.com/wineslab/colosseum-near-rt-ric](https://github.com/wineslab/colosseum-near-rt-ric)
```

### Run setup scripts

```bash
cd colosseum-near-rt-ric/setup-scripts
./import-wines-images.sh
./setup-ric-bronze.sh
```

### Monitor E2Term logs (waiting for gnb connection)

```bash
docker logs e2term -f --since=1s 2>&1 | grep gnb:
```

Terminal 2: Start xApp (Logic)
Once the RIC is ready, start the sample xApp in the second terminal.

```bash

# Go to setup directory

cd /workspace/colosseum-near-rt-ric/setup-scripts

# Start the xApp container

./start-xapp-ns-o-ran.sh

# Run the xApp logic

cd /home/sample-xapp
./run_xapp.sh

```

Terminal 3: ns-3 Network Simulation (RAN)
Finally, compile and run the ns-3 simulation to start sending data to the RIC.

```bash
# Go to workspace
cd /workspace

# Clone ns-3 and the O-RAN interface module
git clone [https://github.com/wineslab/ns-o-ran-ns3-mmwave.git](https://github.com/wineslab/ns-o-ran-ns3-mmwave.git) ns-3-mmwave-oran
cd ns-3-mmwave-oran/contrib 
git clone -b master [https://github.com/o-ran-sc/sim-ns3-o-ran-e2](https://github.com/o-ran-sc/sim-ns3-o-ran-e2) oran-interface

# Configure and Build
cd ../
./ns3 configure --enable-tests --enable-examples
./ns3 build

# Run the scenario
./ns3 run scenario-zero
```
