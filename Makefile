gen-docker-script:
	cat procure_utils.sh procure_docker.sh > dist/docker_setup.sh
	chmod +x dist/docker_setup.sh
	# remove the "source ./procure_utils.sh" line from docker_desktop.sh
	sed -i '' '/source .\/procure_utils\.sh/d' dist/docker_setup.sh
	cat procure_utils.sh procure_nvidia.sh > dist/nvidia_setup.sh
	chmod +x dist/nvidia_setup.sh
	sed -i '' '/source .\/procure_utils\.sh/d' dist/nvidia_setup.sh
