#!/bin/bash

function copyprompt() {
    prompt_pattern=$1
    prompt_dir=~/.prompts
    
    if [ -z "$prompt_pattern" ]; then
        files=`ls $prompt_dir/ | fzf -m`
    else
        files=`ls $prompt_dir/ | grep -i "$prompt_pattern"`
    fi

    echo "$files" | while read -r file; do
        echo "Copying $file"
        cat "$prompt_dir/$file"
        echo -e "\n"
    done | pbcopy
}
