# Usage
```bash
git clone https://github.com/VoodooChild99/circt-workspace.git
cd circt-workspace
./setup.sh
./docker_build.sh circt         # this can be slow
./run.sh circt

# now you're inside the container
cd /home/user
./scripts/build-circt.sh all all        # this can be slow
```