SHELL := /bin/bash

gen-script:
	@cat procure_utils.sh procure_$(script).sh > dist/$(script)_setup.sh
	@chmod +x dist/$(script)_setup.sh
	@sed -i '' '/source .\/procure_utils\.sh/d' dist/$(script)_setup.sh
	@sed -i '' 's/progress_file="progress\.json"/progress_file="progress_$(script)\.json"/' dist/$(script)_setup.sh

gen-setup-scripts:
	@make gen-script script=docker
	@make gen-script script=nvidia
	@make gen-script script=python
	@make gen-script script=full
