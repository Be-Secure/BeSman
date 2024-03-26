#!/bin/bash
 
function __bes_pull {
    local playbook_name="$1"
    local playbook_version="$2"

    __besman_echo_white "Fetching playbooks..."

    if [[ ! -d "$BESMAN_PLAYBOOK_DIR" ]]; then
        mkdir -p "$BESMAN_PLAYBOOK_DIR" || {
            __besman_echo_red "Failed to create playbook directory."
            return 1
        }
    fi

    __besman_fetch_playbook "$playbook_name" "$playbook_version"
    local fetch_result=$?

    case $fetch_result in
        0)
            __besman_echo_green "Playbook $playbook_name $playbook_version added successfully."
            ;;
        1)
            __besman_echo_red "Failed to fetch playbook $playbook_name $playbook_version."
            ;;
        2)
            __besman_echo_yellow "Playbook $playbook_name $playbook_version already exists."
            read -rp "Do you wish to overwrite it? (y/n): " overwrite
            if [[ "$overwrite" == "y" ]]; then
                rm "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh" || {
                    __besman_echo_red "Failed to overwrite existing playbook."
                    return 1
                }
                __besman_fetch_playbook "$playbook_name" "$playbook_version"
                fetch_result=$?
                [[ $fetch_result -eq 0 ]] && __besman_echo_green "Playbook $playbook_name $playbook_version overwritten successfully."
            elif [[ "$overwrite" == "n" ]]; then
                __besman_echo_white "Skipping playbook overwrite."
            else
                __besman_echo_red "Invalid option. Skipping playbook overwrite."
            fi
            ;;
        *)
            __besman_echo_red "Unknown error occurred."
            ;;
    esac

    return $fetch_result
}
 
function __besman_fetch_playbook {
    local playbook_name="$1"
    local playbook_version="$2"
    local playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh"
    local playbook_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/besman-$playbook_name-$playbook_version-playbook.sh"

    if [[ -f "$playbook_file" ]]; then
        return 2
    fi

    __besman_check_url_valid "$playbook_url" || return 1

    if __besman_secure_curl "$playbook_url" >> "$playbook_file"; then
        return 0
    else
        return 1
    fi
}
