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
            __besman_fetch_steps_file "$playbook_name" "$playbook_version" || {
            __besman_echo_red "Failed to fetch steps file for playbook $playbook_name $playbook_version."
            return 1
        }
            __besman_echo_green "Playbook $playbook_name $playbook_version added successfully."
            ;;
        1)
            __besman_echo_red "Failed to fetch playbook $playbook_name $playbook_version."
            ;;
        2)
            __besman_echo_yellow "Playbook $playbook_name $playbook_version already exists."
            read -rp "Do you wish to overwrite it? (y/n): " overwrite
            if [[ "$overwrite" == "y" ]]; then
                rm "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh" || {
                    __besman_echo_red "Failed to overwrite existing playbook."
                    return 1
                }
                __besman_fetch_playbook "$playbook_name" "$playbook_version"
                fetch_result=$?
                [[ $fetch_result -eq 0 ]] && __besman_echo_green "Playbook $playbook_name $playbook_version overwritten successfully."
                __besman_fetch_steps_file "$playbook_name" "$playbook_version"
                fetch_result_steps=$?
                [[ $fetch_result_steps -eq 0 ]] && __besman_echo_green "Steps file $playbook_name $playbook_version overwritten successfully."
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
    local playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
    local playbook_url
    playbook_url=$(__besman_construct_raw_url "$BESMAN_PLAYBOOK_REPO" "$BESMAN_PLAYBOOK_REPO_BRANCH" "playbooks/besman-$playbook_name-playbook-$playbook_version.sh")

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

function __besman_fetch_steps_file() {
    local playbook_name="$1"
    local playbook_version="$2"
    local steps_file_base_name="besman-$playbook_name-steps-$playbook_version"
    local download_url ext raw_url url flag file_name steps_file_path
    extensions=(sh md ipynb)
    # raw_url=$(__besman_construct_raw_url "$BESMAN_PLAYBOOK_REPO" "$BESMAN_PLAYBOOK_REPO_BRANCH" "playbooks/$steps_file_base_name.$ext")
    for ext in "${extensions[@]}"; do
        flag=0
        url=$(__besman_construct_raw_url "$BESMAN_PLAYBOOK_REPO" "$BESMAN_PLAYBOOK_REPO_BRANCH" "playbooks/$steps_file_base_name.$ext")
        # --fail/-f makes curl return non‑zero on 404, --head/-I fetches only headers
        if curl --fail --head "$url" >/dev/null 2>&1; then
            # curl -L "$url" -o "$NAME.$ext"
            download_url="$url"
            flag=1
            break
        fi
    done
    if [[ $flag -eq 0 ]]; then
        __besman_echo_red "No matching steps file found for $playbook_name $playbook_version"
        [[ -f "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh" ]] && rm "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
        return 1
    fi
        
    # to get the extension of the file
    # download_url=$(curl -k -s "$API" | jq -r --arg name "$steps_file_base_name" '.[] | select(.name | test("^" + $name + "\\.(sh|md|ipynb)$")) | .download_url')
    file_name=$(__besman_get_file_name "$download_url")
    steps_file_path="$BESMAN_PLAYBOOK_DIR/$file_name"

    if [[ -n "$download_url" ]]; then
        __besman_echo_white "Downloading steps file"
        __besman_secure_curl "$download_url" > "$steps_file_path"
        return 0
    else
        __besman_echo_red "No matching steps file found"
        [[ -f "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh" ]] && rm "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
        return 1
    fi
}

function __besman_get_file_name() {
  local url="$1"
  local filename

  # 1) GitLab API URL
 if [[ "$url" =~ /repository/files/([^/]+%2F[^/]+\.sh)/raw ]]; then
    # BASH_REMATCH[1] is e.g. playbooks%2Fbesman-…-0.0.1.sh
    local encoded="${BASH_REMATCH[1]}"
    # URL-decode the %2F → “/”
    local decoded
    decoded=$(printf '%b' "${encoded//%/\\x}")
    # Strip everything before the last slash
    filename="${decoded##*/}"

  # 2) GitHub blob URL (e.g. ...github.com/user/repo/blob/branch/path/to/file.ext)
  elif [[ "$url" =~ github\.com/.*/.*/blob/ ]]; then
    # strip query, remove everything up to /blob/branch/
    local tmp="${url%%\?*}"
    # drop up-to-and-including "/blob/<branch>/"
    tmp="${tmp#*blob/}"
    tmp="${tmp#*/}"      # drop the branch name
    filename="${tmp##*/}"

  # 3) Raw GitHub URL (e.g. raw.githubusercontent.com/user/repo/branch/path/to/file.ext)
  elif [[ "$url" =~ raw\.githubusercontent\.com/ ]]; then
    local tmp="${url%%\?*}"
    filename="$(basename "$tmp")"

  # 4) “Normal” GitLab raw or any other URL
  else
    local tmp="${url%%\?*}"
    filename="$(basename "$tmp")"
  fi

  printf '%s\n' "$filename"
}
