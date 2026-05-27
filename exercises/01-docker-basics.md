# Exercise 1: Docker Basics

## Prerequisites
- Docker Desktop installed and running
- Terminal/Command Prompt open

---

## Exercise 1.1: Understanding the Dockerfile

Open `docker/Dockerfile` and answer these questions:
1. What is a **multi-stage build** and why do we use it?
2. Why do we run the app as a **non-root user**?
3. What does `HEALTHCHECK` do?

<details>
<summary>Answers</summary>

1. Multi-stage builds use multiple `FROM` statements. The first stage installs dependencies, and only the needed files are copied to the final stage. This results in a smaller, more secure image.
2. Running as non-root follows the **principle of least privilege** — if the container is compromised, the attacker has limited permissions.
3. `HEALTHCHECK` tells Docker how to test if the container is healthy. Docker will periodically hit the `/health` endpoint.
</details>

---

## Exercise 1.2: Build and Run

```bash
# Build the image
docker build -t poc-app:latest -f docker/Dockerfile .

# Check the image
docker images poc-app

# Run the container
docker run -d --name my-poc -p 5000:5000 poc-app:latest

# Test it
curl http://localhost:5000/health
curl http://localhost:5000/info

# View logs
docker logs my-poc

# Stop and remove
docker stop my-poc && docker rm my-poc
```

---

## Exercise 1.3: Environment Variables

Run with custom environment variables:

```bash
docker run -d --name my-poc \
    -p 5000:5000 \
    -e APP_NAME="My Custom App" \
    -e ENVIRONMENT="testing" \
    -e APP_VERSION="2.0.0" \
    poc-app:latest

curl http://localhost:5000/info
# Notice how the values changed!

docker stop my-poc && docker rm my-poc
```

---

## Exercise 1.4: Interactive Debugging

```bash
# Start a container and get a shell inside it
docker run -it --rm poc-app:latest /bin/bash

# Inside the container, explore:
ls -la
cat requirements.txt
python -c "import flask; print(flask.__version__)"
env | grep APP
exit
```

---

## Exercise 1.5: Image Layers

```bash
# Inspect image layers
docker history poc-app:latest

# Check image size
docker images poc-app

# Compare with a non-multi-stage build
# Try removing the multi-stage build and see how the size changes!
```

---

## Challenge Exercise

Modify the Dockerfile to:
1. Add a `VERSION` build argument (`ARG VERSION=1.0.0`)
2. Set it as an environment variable in the final image
3. Build with: `docker build --build-arg VERSION=2.0.0 -t poc-app:2.0.0 -f docker/Dockerfile .`
4. Verify: `curl http://localhost:5000/info` shows version 2.0.0
