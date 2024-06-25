gen-docker-script:
	cat procure_utils.sh procure_docker.sh > dist/docker_setup.sh
	chmod +x dist/docker_setup.sh
	cat procure_utils.sh procure_nvidia.sh > dist/nvidia_setup.sh
	chmod +x dist/nvidia_setup.sh
