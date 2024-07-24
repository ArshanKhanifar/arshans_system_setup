SHELL := /bin/bash

gen-script:
	@echo '#!/bin/bash' > dist/$(script)_setup.sh
	@echo '' >> dist/$(script)_setup.sh
	@echo 'progress_file=$(script)_setup.json' >> dist/$(script)_setup.sh
	@echo '' >> dist/$(script)_setup.sh
	@cat procure_utils.sh procure_$(script).sh >> dist/$(script)_setup.sh
	@chmod +x dist/$(script)_setup.sh
	@sed -i '' '/source .\/procure_utils\.sh/d' dist/$(script)_setup.sh

gen-setup-scripts:
	@make gen-script script=docker
	@make gen-script script=nvidia
	@make gen-script script=python
	@make gen-script script=profile
	@make gen-script script=chaindev
	@make gen-script script=full
