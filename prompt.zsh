setopt prompt_subst
unsetopt sh_word_split

make() {
    PROMPT="%B"
    
    add_left '$(exit_code_symbolic $(colour_exit_code) " ")'
    add_left '$(exec_time $(colour_exit_code) " ")'
    add_left '$(username $CYAN " ")'
    add_left '$(directory_short $BLUE " " "" 3)'

    #add_left '$(git_branch_ahead_colouring " " "")'
    #add_left '$(git_ahead_symbolic)'
    #add_left '$(git_working_state_symbolic)'
    
    add_left '$(job_count $RED " [" "]" 1)'
    add_left '$(privilege $(colour_privilege) " " " " ">" ">")'

    PROMPT+="%b"

    RPROMPT="%B"
    
    #add_right '$(wifi_status_symbolic " ")'
    #add_right '$(wifi_status_text_if_connected " ")'
    #add_right '$(bluetooth_status_symbolic " ")'
    #add_right '$(bluetooth_status_text_if_connected " " "" $BLUE)'
    #add_right '$(battery_percentage_symbolic " ")'

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

ICON_TICK="✔"
ICON_CROSS="✘"
ICON_ROOT="#"
ICON_USER="$"
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

#================================== TO DO ====================================#
# - Make du -h alias                                                          #
# - Show number of up/downstream missing                                      #
# - Cache computed values                                                     #
#=============================================================================#

#================================= HELPERS ===================================#

function add_left() {
	PROMPT+="$1%f"
}

function add_right() {
	RPROMPT+="$1%f"
}

#================================= COLOURS ===================================#
#             Use to provide conditional colouring to a component             #
#=============================================================================#

# Colour based on exit code of last command.
function colour_exit_code() {
    echo "%(0?.$GREEN.%(127?.$YELLOW.%(130?.$GREY.$RED)))"
}

# Colour based on current privilege level.
function colour_privilege() {
 echo "%(!.$RED.$GREEN)"
}

#============================ VANILLA COMPONENTS =============================#
#     Unless otherwise stated, $1 = Colour, $2 = Prefix, and $3 = Suffix      #
#=============================================================================#

# Date as "DD/MM/YY"
function date_short() {
    echo $1$2%D{%d/%m/%y}$3%f
}

# Date as "Day DD Mon YYYY"
function date_long() {
    echo $1$2%D{%a %d %b %Y}$2%f
}

# 12 Hour Time as "HH:MM:SS AM"
function time_ampm() {
	echo $1$2%D{%r}$2%f
}

# 12 Hour Time as "HH:MM:SS"
function time_12() {
	echo $1$2%D{%I:%M:%S}$2%f
}

# 24 Hour Time as "HH:MM:SS"
function time_24() {
    echo $1$2%D{%H:%M:%S}$3%f
}

# Fully qualified directory. $4 = Number of levels to show.
function directory_full() {
    echo $1$2%$4/$3%f
}

# Directory starting at "~" if in "/home/user". $4 = Number of levels to show.
function directory_short() {
    echo $1$2%$4~$3%f
}

# Number of visible files/directories in current directory.
function file_count() {
    echo $1$2$(ls -1 | wc -l)$3%f
}

# Number of all files/directories in current directory.
function file_count_all() {
    echo $1$2$(ls -1A | wc -l)$3%f
}

# Size of visible files in the current directory.
function file_size() {
    echo $1$2$(ls -sh | head -1 | cut -d" " -f2)$3%f
}

# Size of all files in the current directory.
function file_size_all() {
    echo $1$2$(ls -sha | head -1 | cut -d" " -f2)$3%f
}

# Size of all files and directories in the current directory. (VERY SLOW)
function file_and_directory_size() {
    echo -n $1$2$(du -sh | cut -f 1)$3%f
}

# Execution time of last command in seconds.
function exec_time() {
    if [[ -z $last_exec_time ]] && return
    echo $1$2$last_exec_time"s"$3%f
}

# Number of background jobs. (Optional) Only show if greater than $4.
function job_count() {
    echo "%($4j.$1$2%j$3%f.)"
}

# Depth of current shell. (Optional) Only show if greater than $4.
function shell_level() {
	echo "%$4(L.$1$2%L$3%f.)"
}

# Terminal name/number, e.g. tty1
function terminal_number() {
    echo $1$2%l$3%f
}

# Username.
function username() {
    echo $1$2%n$3%f
}

# Hostname.
function hostname() {
    echo $1$2%m$3%f
}

# Fully qualified hostname, e.g. myhost.mydomain.
function hostname_fully_qualified() {
    echo $1$2%M$3%f
}

# Exit code of last command.
function exit_code() {
    echo $1$2"%?"$3%f
}

# Exit code of last command represented by icons.
function exit_code_symbolic() {
    echo $1$2"%(0?.$ICON_TICK.$ICON_CROSS)"$3%f
}

# Privilege level displayed as $4 if root or $5 if user.
function privilege() {
    echo $1$2"%(!.$4.$5)"$3%f
}

#================================= NETWORK ===================================#
#                  Network status provided by Network Manager                 #
#=============================================================================#

PROMPT_WIFI_ABLE=""
PROMPT_WIFI_ABLE_SET=false
PROMPT_WIFI_NETWORK=""
PROMPT_WIFI_NETWORK_SET=false

# Helper to prevent stats being recalculated in a single prompt.
function calculate_wifi_status() {
    if [[ !$PROMPT_WIFI_ABLE_SET ]]; then
        $PROMPT_WIFI_ABLE=$(nmcli radio wifi 2> /dev/null)
        $PROMPT_WIFI_ABLE_SET=true
    fi
    if [[ !$PROMPT_WIFI_NETWORK_SET ]]; then
        $PROMPT_WIFI_NETWORK=$(nmcli -t -f TYPE,CONNECTION device 2> /dev/null | grep wifi | cut -d: -f2)
        $PROMPT_WIFI_NETWORK_SET=true
    fi
}

# Return colour $1, $2, $3 if disconnected, connecting, connected.
function colour_wifi_custom() {
    $(calculate_wifi_status)
    
    if [[ $PROMPT_WIFI_ABLE == "enabled" ]]; then
        if [[ $PROMPT_WIFI_NETWORK == "--" ]]; then
            echo $1
        elif [[ $PROMPT_WIFI_NETWORK == "(configuring)" ]]; then
            echo $2
        elif [[ $PROMPT_WIFI_NETWORK == "" ]]; then
            echo $1
        else
            echo $3
        fi
    else
        echo $1
    fi
}

# Traffic light colouring for disconnected, connecting, connected.
function colour_wifi_trafficlight() {
    echo $(colour_wifi_custom $RED $YELLOW $GREEN)
}

# Grey, White, Cyan/$1 colouring for disconnected, connecting, connected.
function colour_wifi_mono() {
    echo $(colour_wifi_custom $RED $YELLOW $CYAN$1)
}

# Display custom text based on WiFi status
# $1 = Disabled $2 = Disconnected $3 = Connecting $4 = Connected
function wifi_status_custom() {   
    $(calculate_wifi_status)

    if [[ -z $3 ]]; then
        $3=$PROMPT_WIFI_NETWORK
    fi
    
    if [[ $wifi_state == "enabled" ]]; then
        if [[ $PROMPT_WIFI_NETWORK == "--" ]]; then
            echo $2
        elif [[ $PROMPT_WIFI_NETWORK == "(configuring)" ]]; then
            echo $3
        elif [[ $PROMPT_WIFI_NETWORK == "" ]]; then
            echo $2
        else
            echo $4
        fi
    else
        echo $1
    fi
}

# WiFi icon, intended to be used with some colour_wifi for colour.
function wifi_status_icon() {
    echo $1$2$ICON_WIFI$3%f
}

# Descriptive WiFi status text.
function wifi_status_text() {
    echo $1$2$(wifi_status_custom "disabled" "disconnected" "connecting" $PROMPT_WIFI_NETWORK)$3%f
}

# Descriptive WiFi status text only if WiFi is enabled.
function wifi_status_text_if_enabled() {
    echo $(wifi_status_custom "" $1$2"disconnected"$3%f $1$2"connecting"$3%f $1$2$PROMPT_WIFI_NETWORK$3%f)
}

# Name of connected network.
function wifi_network_if_connected() {
    echo $(wifi_status_custom "" "" "" $1$2$PROMPT_WIFI_NETWORK$3%f)
}

# Strength of connected network.
function wifi_strength() {
    $(calculate_wifi_status)
    
    if [[ $PROMPT_WIFI_ABLE == "enabled" ]] && return
    if [[ $PROMPT_WIFI_NETWORK == "--" ]] && return
    if [[ $PROMPT_WIFI_NETWORK == "" ]] && return
    if [[ $PROMPT_WIFI_NETWORK == "(configuring)" ]] && return

    local $PROMPT_WIFI_STRENGTH=$(nmcli -t -f IN-USE:SSID:SIGNAL device wifi 2> /dev/null | grep \*$wifi_network | cut -d: -f3 )
    
    if [[ $wifi_strength != "" ]] && return
    
    echo $1$2$PROMPT_WIFI_STRENGTH%%$3%f
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
    
    echo -n "$ICON_BLUETOOTH%f$2%f"
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
    local battery_info=$(acpi 2> /dev/null | tr -d ",%")
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
    
    echo -n "%f$2%f"
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
    $PROMPT_WIFI_ABLE_SET=false
    $PROMPT_WIFI_NETWORK_SET=false
}

function precmd() {
	if [[ $timer ]]; then
        last_exec_time=$(($SECONDS - $timer))
    fi
	unset timer
}

make
