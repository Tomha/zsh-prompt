setopt prompt_subst
unsetopt sh_word_split

make() {
    PROMPT="%B"
    
    add_left '$(exit_code_symbolic " ")'
    add_left '$(exec_time_exit_code_colouring " ")'
    add_left '$(directory_short " " "" $BLUE 3)'

    add_left '$(git_branch_ahead_colouring " " "")'
    add_left '$(git_ahead_symbolic)'
    add_left '$(git_working_state_symbolic)'
    
    add_left '$(privilege_prompt_plain " " " " ">")'
        
    PROMPT+="%b"

    RPROMPT="%B"
    
    add_right '$(time_12 "" "" $YELLOW)'
    
    RPROMPT+="%b "
}

#=============================================================================#

# Notes:
# setopt prompt_subst needed to allow evaluation in prompt
# Use single quotes if you want to evaluate on prompt generation
# Prompt made of functions to easily rearrange
# Pass pre/postfix and colours to functions to easily tweak appearance

#=============================================================================#

GREY="%F{0}"
RED="%F{1}"
GREEN="%F{2}"
YELLOW="%F{3}"
BLUE="%F{4}"
PURPLE="%F{5}"
CYAN="%F{6}"
WHITE="%F{7}"

# Requires Font Awesome
ICON_WIFI=" "
ICON_BLUETOOTH=""
ICON_BATTERY_1=" "
ICON_BATTERY_2=" "
ICON_BATTERY_3=" "
ICON_BATTERY_4=" "
ICON_BATTERY_5=" "
ICON_VOLUME_MUTE="✕"
ICON_VOLUME_3=" "
ICON_VOLUME_2=" "
ICON_VOLUME_1=" "
ICON_GIT=""

# Git - Need to check upstream exists

#https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

# Make an alias to show du -h with ls type alias


#================================= HELPERS ===================================#

function add_left() {
	PROMPT+="$1%f"
}

function add_right() {
	RPROMPT+="$1%f"
}

#================================= METHODS ===================================#

#######################
#      Date/Time      #
#######################

# DD/MM/YY formatted date
# $1=Prefix $2=Suffix $3=TextColour
function date_short() {
    echo -n "$1%f$3%D{%d/%m/%y}%f$2%f"
}

# Mon 01 Jan 2017 formatted date
# $1=Prefix $2=Suffix $3=TextColour
function date_long() {  
    echo -n "$1%f$3%D{%a %d %b %Y}%f$2%f"
}

# 12 Hour Time with AM/PM
# $1=Prefix $2=Suffix $3=TextColour
function time_ampm() {    
	echo "$1%f$3%D{%r}%f$2%f"
}

# 12 Hour Time without AM/PM
# $1=Prefix $2=Suffix $3=TextColour
function time_12() {    
	echo "$1%f$3%D{%I:%M:%S}%f$2%f"
}

# 24 Hour Time
# $1=Prefix $2=Suffix $3=TextColour
function time_24() {    
    echo "$1%f$3%D{%H:%M:%S}%f$2%f"
}


#######################
#      Directory      #
#######################

# Directory starting at /
# $1=Prefix $2=Suffix $3=TextColour $4=LevelsToShow
function directory_full() {   
    echo -n "$1%f$3%$4/%f$2%f"
}

# Directory starting at ~ if in home directory
# $1=Prefix $2=Suffix $3=TextColour $4=LevelsToShow
function directory_short() {
    echo -n "$1%f$3%$4~%f$2%f"
}

# Number of visible files in current directory.
# $1=Prefix $2=Suffix $3=TextColour
function directory_file_count() {
    echo -n "$1%f$3$(ls -1 | wc -l)%f$2%f"
}

# Number of all files in current directory.
# $1=Prefix $2=Suffix $3=TextColour
function directory_file_count_all() {
    echo -n "$1%f$3$(ls -1A | wc -l)%f$2%f"
}

# Size of visible files in the current directory.
# $1=Prefix $2=Suffix $3=TextColour
function directory_file_size() {
    echo -n "$1%f$3$(ls -sh | head -1 | cut -d " " -f 2)%f$2%f"
}

# Size of all files in the current directory (only).
# $1=Prefix $2=Suffix $3=TextColour
function directory_file_size_all() {
    echo -n "$1%f$3$(ls -ash | head -1 | cut -d " " -f 2)%f$2%f"
}

# Recursive size of all files and directories (SLOW).
# $1=Prefix $2=Suffix $3=TextColour
function directory_total_size_slow() {
    echo -n "$1%f$3$(du -sh | cut -f 1)%f$2%f"
echo -n "$1%f$3$(du -sh | cut -f 1)%f$2%f"
}

#######################
# Command Exec Times  #
#######################

# Last command execution time (seconds).
# $1=Prefix $2=Suffix $3=TextColour
function exec_time() {
    if [[ $last_exec_time ]]; then    
        echo -n "$1%f$3"$last_exec_time"s%f$2%f"
    fi
}

# Last command execution time (seconds) if longer than.
# $1=Prefix $2=Suffix $3=TextColour $4=$ShowIfLongerThan
function exec_time_if_longer_than() {
    if [[ $last_exec_time ]] && (($last_exec_time > $4 )); then        
            echo -n "$1%f$3"$last_exec_time"s%f$2%f"
    fi
}

# Last command execution time (seconds) coloured by exit code.
# $1=Prefix $2=Suffix
function exec_time_exit_code_colouring() {
    echo -n "$1%f%(0?.$GREEN.%(127?.$YELLOW.%(130?.$GREY.$RED)))"$last_exec_time"s%f$2%f"
}

#######################
#     Job Counts      #
#######################

# Number of background jobs.
# $1=Prefix $2=Suffix $3=TextColour
function job_count() {   
    echo -n "$1%f$3%j%f$2%f"
}

# Number of background jobs if greater than.
# $1=Prefix $2=Suffix $3=TextColour $4=ShowIfAtLeast
function job_count_if_at_least() {
    echo -n "%($4j.$1%f$3%j%f$2%f.)"
}

#######################
#     Shell Level     #
#######################

# Depth of current shell.
# $1=Prefix $2=Suffix $3=TextColour
function shell_level() {    
	echo "$1%f$3%L%f$2%f"
}

# Depth of current shell if greater than.
# $1=Prefix $2=Suffix $3=TextColour $4=ShowIfAtLeast
function shell_level_if_at_least() {    
	echo "%$4(L.$1%f$3%L%f$2%f.)"
}

#######################
#    Terminal Info    #
#######################

# Name of the current terminal, e.g. /dev/tty0, with /dev stripped.
# $1=Prefix $2=Suffix $3=TextColour
function terminal_number() {
    echo "$1%f$3%l%f$2%f"
}

#######################
#      Username       #
#######################

# Username.
# $1=Prefix $2=Suffix $3=TextColour
function username() {
        echo "$1%f$3%n%f$2%f"
}

#######################
#      Hostname       #
#######################

# Simple hostname e.g. myhost
# $1=Prefix $2=Suffix $3=TextColour
function hostname() {    
    echo -n "$1%f$3%m%f$2%f"
}

# Fully qualified hostname e.g. myhost.mydomain
# $1=Prefix $2=Suffix $3=TextColour
function hostname_full() {    
    echo -n "$1%f$3%M%f$2%f"
}

# Fully qualified hostname if connected over ssh.
# $1=Prefix $2=Suffix $3=TextColour
function hostname_if_in_ssh() {   
    if [[ $SSH_CONNECTION ]]; then
        echo -n "$1%f$3%M%f$2%f"
    fi
}

#######################
#      Exit Code      #
#######################

# Last command exit code.
# $1=Prefix $2=Suffix
function exit_code() {
    echo -n "$1%f$3%?%f$2%f"
}

# Last command exit code, coloured.
# Green = Success. Yellow = Unknown Command. Red = Failure. Grey = Ctrl+C.
# $1=Prefix $2=Suffix
function exit_code_coloured() {
    echo -n "$1%f%(0?.$GREEN?.%(127?.$YELLOW?.%(130?.$GREY?.$RED?)))%f$2%f"
}

# Last command's exit code, coloured icon.
# Green = Success. Yellow = Unknown Command. Red = Failure. Grey = Ctrl+C.
# $1=Prefix $2=Suffix
function exit_code_symbolic() {    
    echo -n "$1%f%(0?.$GREEN✔.%(127?.$YELLOW✘.%(130?.$GREY✘.$RED✘)))%f$2%f"
}

#######################
#   Privilege Level   #
#######################

# Text to show only when running privileged.
# $1=Prefix $2=Suffix $3=TextColour
function privilege_flag() {
    echo -n "%(!.$1%f$3%f$2%f.)"
}

# Last command exit code, coloured.
# $1=Prefix $2=Suffix $3=RootText $4=UserText
function privilege_text() {
    echo -n "$1%f%(!.$3.$4)%f$2%f"
}


# Username coloured by privilege level
# $1=Prefix $2=Suffix
function privilege_username() {
    echo -n "$1%f%(!.$RED%n.$GREEN%n)%f$2%f"
}

#######################
#       Prompts       #
#######################

# Prompt char coloured by exit code of last command.
# $1=Prefix $2=Suffix $3=PromptChar
function exit_code_prompt() {
    echo -n "$1%f%(0?.$GREEN.%(127?.$YELLOW.%(130?.$GREY.$RED)))$3%f$2%f"
}

# Prompt char set and coloured by privilege level.
# $1=Prefix $2=Suffix
function privilege_prompt() {
    echo -n "$1%f%(!.$RED#.$GREEN$)%f$2%f"
}

# Prompt char coloured by privilege level.
# $1=Prefix $2=Suffix $3=PromptChar
function privilege_prompt_plain() {   
    echo -n "$1%f%(!.$RED.$GREEN)$3%f$2%f"
}

#######################
#      Network        #
#######################
# Requires Network Manager

# WiFi connection state as colour coded icon.
# $1=Prefix $2=Suffix
function wifi_status_symbolic() {   
    echo -n "$1%f"
    
    local wifi_state=$(nmcli radio wifi 2> /dev/null)
    local wifi_network=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d ":" -f 2)

    if [[ $wifi_state -eq "enabled" ]]; then
        if [[ $wifi_network == "--" ]]; then
            echo -n $WHITE
        elif [[ $wifi_network == "(configuring)" ]]; then
            echo -n $CYAN
        elif [[ $wifi_network == "" ]]; then
            echo -n $GREY
        else
            echo -n $GREEN
        fi
    else
        echo -n $GREY
    fi
    
    echo -n "$WIFI_ICON%f$2%f"
}

# WiFi connection state as text description.
# $1=Prefix $2=Suffix
function wifi_status_text() {
    echo -n "$1%f"

    local wifi_state=$(nmcli radio wifi 2> /dev/null)
    local wifi_network=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d ":" -f 2)

    if [[ $wifi_state -eq "enabled" ]]; then
        if [[ $wifi_network == "--" ]]; then
            echo -n $RED"disconnected"
        elif [[ $wifi_network == "(configuring)" ]]; then
            echo -n $YELLOW"connecting"
        elif [[ $wifi_network == "" ]]; then
            echo -n $RED"disabled"
        else
            echo -n $GREEN"$wifi_network"
        fi
    else
        echo -n $RED"disabled"
    fi
    
    echo -n "%f$2%f"
}

# WiFi connection state as text description if WiFi is enabled.
# $1=Prefix $2=Suffix
function wifi_status_text_if_enabled() {
    local wifi_state=$(nmcli radio wifi 2> /dev/null)
    local wifi_network=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d ":" -f 2)

    if [[ $wifi_state -eq "enabled" ]]; then
        if [[ $wifi_network == "--" ]]; then
            echo -n "%f$2%f"$RED"disconnected$1%f"
        elif [[ $wifi_network == "(configuring)" ]]; then
            echo -n "%f$2%f"$YELLOW"connecting$1%f"
        elif [[ $wifi_network != "" ]]; then
            echo -n "%f$2%f"$GREEN"$wifi_network$1%f"
        fi
    fi
}

# WiFi connection state as text description if connected to a network.
# $1=Prefix $2=Suffix
function wifi_status_text_if_connected() {
    local wifi_state=$(nmcli radio wifi 2> /dev/null)
    local wifi_network=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d ":" -f 2)

    if [[ $wifi_state == "enabled" && $wifi_network != "" && $wifi_network != "(configuring)" && $wifi_network != "--" ]]; then
        echo -n $1%f$3$network%f$2%f
    fi
}

# WiFi connection strength.
# $1=Prefix $2=Suffix $3=TextColour
function wifi_strength() {
    local wifi_state=$(nmcli radio wifi 2> /dev/null)
    local wifi_network=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d ":" -f 2)
    
    if [[ $wifi_state == "enabled" && $wifi_network != "" && $wifi_network != "(configuring)" && $wifi_network == "--" ]]; then
        local wifi_strength=$(nmcli -t -f IN-USE:SSID:SIGNAL device wifi 2> /dev/null | grep \*$wifi_network | cut -d ":" -f 3 )
        if [[ $wifi_strength != "" ]]; then
            echo -n $1%f$3$wifi_strength%%f$2%f
        fi
    fi
}

#######################
#      Bluetooth      #
#######################
# Requires Bluez Utils

function bluetooth_status_symbolic() {   
    echo -n "$1%f"
    
    local bluetooth_powered=$(btmgmt info 2> /dev/null | grep "current settings:.*powered")
    local bluetooth_info=$(echo info | bluetoothctl 2> /dev/null)
    local bluetooth_connected=$(echo $bluetooth_info | grep Connected: | cut -d " " -f 2)

    if [[ $bluetooth_powered != "" ]]; then
        if [[ $bluetooth_connected == "yes" ]]; then
            echo -n $BLUE
        else
            echo -n $WHITE
        fi
    else
        echo -n $GREY
    fi
    
    echo -n "$BLUETOOTH_ICON%f$2%f"
}

function bluetooth_status_text() {
    local bluetooth_powered=$(btmgmt info 2> /dev/null | grep "current settings:.*powered")
    local bluetooth_info=$(echo info | bluetoothctl 2> /dev/null)
    local bluetooth_connected=$(echo $bluetooth_info | grep Connected: | cut -d " " -f 2)
    local bluetooth_name=$(echo $bluetooth_info | grep Name: | cut -d " " -f 2)

    if [[ $bluetooth_powered != "" ]]; then
        if [[ $bluetooth_connected == "yes" ]]; then
            echo -n "%f$1%f$BLUE$bluetooth_name$2%f"
        else
            echo -n "%f$1%f"$WHITE"disconnected$2%f"
        fi
    else
        echo -n "%f$1%f"$GREY"disabled$2%f"
    fi
}

function bluetooth_status_text_if_connected() {
    local bluetooth_powered=$(btmgmt info 2> /dev/null | grep "current settings:.*powered")
    local bluetooth_info=$(echo info | bluetoothctl 2> /dev/null)
    local bluetooth_connected=$(echo $bluetooth_info | grep Connected: | cut -d " " -f 2)
    local bluetooth_name=$(echo $bluetooth_info | grep Name: | cut -d " " -f 2)

    if [[ $bluetooth_powered != "" && $bluetooth_connected == "yes" ]]; then
        echo -n "%f$1%f$BLUE$bluetooth_name$2%f"
    fi
}

#######################
#       Battery       #
#######################
# Requires acpi

function battery_status_symbolic() {
    local battery_info=$(acpi 2> /dev/null | tr -d ",")
    local battery_status=$(echo $battery_info | cut -d " " -f 3)
    
    echo -n "%f$1%f"
        
    if [[ $battery_status == "Discharging" ]]; then
        echo -n "$RED↓"
    elif [[ $battery_status == "Charging" ]]; then
        echo -n "$YELLOW↑"
    elif [[ $battery_status == "Charged" ]]; then
        echo -n "$GREEN✓"
    fi
        
    echo -n "%f$2%f"
}

function battery_status_text() {
    local battery_info=$(acpi 2> /dev/null | tr -d ",")
    local battery_status=$(echo $battery_info | cut -d " " -f 3)
    echo -n "%f$1%f$3$battery_status%f$2%f"
}

function battery_percentage_symbolic() {
    local battery_info=$(acpi 2> /dev/null | tr -d ",")
    local battery_percentage=$(echo $battery_info | cut -d " " -f 4)

    echo -n "%f$1%f"
    
    if (( $battery_percentage > 95 )); then
        echo -n $GREEN$ICON_BATTERY_5
    elif (( $battery_percentage > 75 )); then
        echo -n $YELLOW$ICON_BATTERY_4
    elif (( $battery_percentage > 50 )); then
        echo -n $YELLOW$ICON_BATTERY_3
    elif (( $battery_percentage > 5 )); then
        echo -n $RED$ICON_BATTERY_2
    else
        echo -n $RED$ICON_BATTERY_1
    fi
    
    echo -n "$battery_percentage%%f$2%f"
}

function battery_percentage_text() {
    local battery_info=$(acpi 2> /dev/null | tr -d ",%")
    local battery_percentage=$(echo $battery_info | cut -d " " -f 4)

    echo -n "%f$1%f"
    
    if (( $battery_percentage > 75 )); then
        echo -n $GREEN
    elif (( $battery_percentage > 25 )); then
        echo -n $YELLOW
    else
        echo -n $RED
    fi
    
    echo -n "$battery_percentage%%%f$2%f"
}

function battery_time_remaining() {
    local battery_info=$(acpi 2> /dev/null | tr -d ",")
    local battery_time=$(echo $battery_info | cut -d " " -f 5)
    local battery_status=$(echo $battery_info | cut -d " " -f 3)
    
    echo -n "%f$1%f"

    if [[ $battery_status == "Discharging" ]]; then
        echo -n $RED
    elif [[ $battery_status == "Charging" ]]; then
        echo -n $YELLOW
    elif [[ $battery_status == "Charged" ]]; then
        echo -n $GREEN
    fi
    
    echo -n "$battery_time%f$2%f"
}

#######################
#       Volume        #
#######################
# Requires amixer

# TODO: Volume icons that work

function volume_symbolic() {
    local volume_info=$(amixer | grep "Front Left: Playback" | tr -d "[]:%")
    local volume_power=$(echo $volume_info | cut -d " " -f 8)
    local volume_level=$(echo $volume_info | cut -d " " -f 7)
    
    echo -n "%f$1%f$3"
    
    if [[ $volume_power == "off" ]]; then
        echo -n $ICON_VOLUME_MUTE
    else
        if (( $volume_level > 75 )); then
            echo -n $ICON_VOLUME_3
        elif (( $volume_level > 25 )); then
            echo -n $ICON_VOLUME_2
        elif (( $volume_level > 5 )); then
            echo -n $ICON_VOLUME_1
        else
            echo -n $ICON_VOLUME_MUTE
        fi
    fi

    echo -n "%f$2%f"
}

function volume_text() {
    local volume_info=$(amixer | grep "Front Left: Playback" | tr -d "[]:%")
    local volume_power=$(echo $volume_info | cut -d " " -f 8)
    local volume_level=$(echo $volume_info | cut -d " " -f 7)
    
    echo -n "%f$1%f$3"
    
    if [[ $volume_power == "off" ]]; then
        echo -n "muted"
    else
        echo -n "$volume_level%%"
    fi

    echo -n "%f$2%f"
}

#######################
#         Git         #
#######################

# TODO: Count of branchs ahead/behind?

# Show the current git branch if in a git repo.
# $1=Prefix $2=Suffix $3=Colour
function git_branch() {
    if [[ $(git rev-parse --git-dir 2> /dev/null) != "" ]]; then
        local git_branch=$(git rev-parse --abbrev-ref @ 2> /dev/null)
        echo -n "$1%f$3$git_branch%f$2%f"
    fi
}

# Show the current git branch if in a git repo, coloured by master ahead/behind state.
# $1=Prefix $2=Suffix
function git_branch_ahead_colouring() {
    if [[ $(git rev-parse --git-dir 2> /dev/null) != "" ]]; then
        local git_branch=$(git rev-parse --abbrev-ref @ 2> /dev/null)
        if [[ $(git rev-parse @{u} 2> /dev/null) != "" ]]; then
            local base_commit=$(git merge-base @ @{u})
            local local_commit=$(git rev-parse @)
            local remote_commit=$(git rev-parse @{u})
        
            echo -n "$1%f"
        
            if [[ $local_commit = $remote_commit ]]; then
                echo -n $GREEN # Up to date
            elif [[ $local_commit = $base_commit ]]; then
                echo -n $RED # Behind
            elif [[ $remote_commit = $base_commit ]]; then
                echo -n $YELLOW # Ahead
            else
                echo -n $PURPLE # Diverged
            fi

            echo -n "$git_branch%f$2%f"
        else
            echo -n "$1%f$GREY$git_branch%f$2%f" # No upstream
        fi
    fi
}

# Current branch ahead/behind master state as a coloured icon.
# $1=Prefix $2=Suffix
function git_ahead_symbolic() {
    if [[ $(git rev-parse --git-dir 2> /dev/null) != "" ]]; then
        local git_branch=$(git rev-parse --abbrev-ref @ 2> /dev/null)
        if [[ $(git rev-parse @{u} 2> /dev/null) != "" ]]; then
            local base_commit=$(git merge-base @ @{u})
            local local_commit=$(git rev-parse @)
            local remote_commit=$(git rev-parse @{u})
        
            echo -n "$1%f"
        
            if [[ $local_commit = $remote_commit ]]; then
                echo -n "$GREEN✓" # Up to date
            elif [[ $local_commit = $base_commit ]]; then
                echo -n "$RED↓" # Behind
            elif [[ $remote_commit = $base_commit ]]; then
                echo -n "$YELLOW↑" # Ahead
            else
                echo -n "$PURPLE↗" # Diverged
            fi

            echo -n "%f$2%f"
        fi
    fi
}

# Number of added/deleted/modified/etc. files in working/staging with coloured text key.
# $1=Prefix $2=Suffix.
function git_working_state_text() {   
    if [[ $(git rev-parse --git-dir 2> /dev/null) == "" ]] && return
    if [[ $(git status --short 2> /dev/null) == "" ]] && return
    
    local uncommitted_files=$(git status --short | awk '{$1=$1};1')
    local added=$(echo $uncommitted_files | cut -d " " -f 1 | grep "A" | wc -l)
    local deleted=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'D' | wc -l)
    local modified=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'M' | wc -l)
    local renamed=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'R' | wc -l)
    local untracked=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep '?' | wc -l)

    echo -n "$1%f"
    
    if [[ $modified -gt 0 ]]; then
        echo -n " "$YELLOW$modified"m"
    fi 
    if [[ $added -gt 0 ]]; then
        echo -n " "$GREEN$added"a"
    fi
    if [[ $deleted -gt 0 ]]; then
        echo -n " "$RED$deleted"d"
    fi
    if [[ $renamed -gt 0 ]]; then
        echo -n " "$BLUE$renamed"r"
    fi
    if [[ $untracked -gt 0 ]]; then
        echo -n " "$GREY$untracked"u"
    fi
    
    echo -n "%f$2%f"
}

# Number of added/deleted/modified/etc. files in working/staging with coloured icon key.
# $1=Prefix $2=Suffix.
function git_working_state_symbolic() {   
    if [[ $(git rev-parse --git-dir 2> /dev/null) == "" ]] && return
    if [[ $(git status --short 2> /dev/null) == "" ]] && return
    
    local uncommitted_files=$(git status --short | awk '{$1=$1};1')
    local added=$(echo $uncommitted_files | cut -d " " -f 1 | grep "A" | wc -l)
    local deleted=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'D' | wc -l)
    local modified=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'M' | wc -l)
    local renamed=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep 'R' | wc -l)
    local untracked=$(echo $uncommitted_files | cut -d ' ' -f 1 | grep '?' | wc -l)

    echo -n "$1%f"
    
    if [[ $modified -gt 0 ]]; then
        echo -n " "$YELLOW$modified"*"
    fi 
    if [[ $added -gt 0 ]]; then
        echo -n " "$GREEN$added"+"
    fi
    if [[ $deleted -gt 0 ]]; then
        echo -n " "$RED$deleted"-"
    fi
    if [[ $renamed -gt 0 ]]; then
        echo -n " "$BLUE$renamed"^"
    fi
    if [[ $untracked -gt 0 ]]; then
        echo -n " "$GREY$untracked"~"
    fi
    
    echo -n "%f$2%f"
}

# Flag to show if current branch is behind master.
# $1=Prefix $2=Suffix $3=TextColour
function git_behind_flag() {   
    if [[ $(git rev-parse --git-dir 2> /dev/null) == "" ]] && return
    if [[ $(git rev-parse @{u} 2> /dev/null) == "" ]] && return

    local base_commit=$(git merge-base @ @{u})
    local local_commit=$(git rev-parse @)
    local remote_commit=$(git rev-parse @{u})
    
    if [[ $local_commit != $remote_commit && $local_commit == $base_comit ]]; then
        echo -n "$1%f$3⚑%f$2%f"
    fi
}

#=============================================================================#

function preexec() {
	timer=${timer:-$SECONDS}
}

function precmd() {
	if [[ $timer ]]; then
        last_exec_time=$(($SECONDS - $timer))
    fi
	unset timer
}

#=============================================================================#

# MAX LENGTH INCLUDES ANY FOLLOWING PROMPT ELEMENTS
function directory_trim() {
    local colour=$1
    local prefix=$2
    local suffix=$3
    local levels=$4
    local length=$5
    
    echo -n "$prefix%f$colour"
    echo -n "%$length<...<%$levels~"
    echo -n "%f$suffix%f"
}


make
