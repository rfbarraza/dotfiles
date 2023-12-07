#!/usr/bin/env bash
#
####################:##########################################################
#                                                                            #
#░█▀▀░█▀█░█░█░█▀▀░░░░░█░█░█░█░█▀▀░█▀▄░░░░░█▀▀░▀█▀░█▀█░▀█▀░█░█░█▀▀░░░░█▀▀░█░█ #
#░▀▀█░█▀█░█▀▄░█▀▀░▄▄▄░█▄█░░█░░▀▀█░█░█░▄▄▄░▀▀█░░█░░█▀█░░█░░█░█░▀▀█░░░░▀▀█░█▀█ #
#░▀▀▀░▀░▀░▀░▀░▀▀▀░░░░░▀░▀░░▀░░▀▀▀░▀▀░░░░░░▀▀▀░░▀░░▀░▀░░▀░░▀▀▀░▀▀▀░▀░░▀▀▀░▀░▀ #
#                                                                            #
#                                                                            #
#Check the status of wysd machines (with the help of Wireguard)              #
#                                                                            #
##############################################################################


CMD_HELP_MESSAGE='
Command line options:
    -W          Automatically connect via Wireguard
    -h          Print help 
'
CMD_OPTIONS=":Wh"
E_OPTERROR=85 # non-reserved code

doWG=0
while getopts "$CMD_OPTIONS" options; do
    case $options in
        h)
            echo "$CMD_HELP_MESSAGE" 
            exit $E_OPTERROR
            ;;
        W)
            doWG=1
            ;;
        \?)
            echo "$CMD_HELP_MESSAGE"
            exit 1
            ;;
    esac
done

didWGUp=0

function WGUp() {
    echo "// ----------------------"
    echo "// Connecting to Wayside"
    echo "// ----------------------"

    wg-quick up Wayside
    didWGUp=1
}

function WGDown() {
    echo "// ----------------------"
    echo "// Disconnecting"
    echo "// ----------------------"

    wg-quick down Wayside
}

function CheckWysdStatus () {
    {
        sh_header -n "Wayside Report" -d "Server Status and Logs"
        sake -c ~/.config/sake/sake.yaml run wysd-ping;
        sake -c ~/.config/sake/sake.yaml run wysd-info;
        echo "# ###################################################################"
        echo "# Docker"
        echo "# ###################################################################"
        echo ""
        echo ""
        sake -c ~/.config/sake/sake.yaml run wysd-docker-status;
        echo ""
        echo ""
        echo "# ###################################################################"
        echo "# Call Attendant"
        echo "# ###################################################################"
        sake -c ~/.config/sake/sake.yaml run callattendant-status;
        sake -c ~/.config/sake/sake.yaml run phonecalls;
        echo ""
        echo ""
        echo "# ###################################################################"
        echo "# E-Mail"
        echo "# ###################################################################"
        sake -c ~/.config/sake/sake.yaml run dads-email;
        echo ""
        echo ""
        echo "# ###################################################################"
        echo "# Unknown Hosts"
        echo "# ###################################################################"
        sake -c ~/.config/sake/sake.yaml run wysd-unknowns;
        echo ""
        echo ""
    } | sed 's/\[[0-9;]*m//g' | sed 's/\[0;1m//g' > ~/Documents/Family/Wayside/Status/sake-report-$(date +%Y-%m-%d).txt
}

function Main() {
    if [[ "$doWG" -eq 1 ]]; then
        WGUp
    fi

   CheckWysdStatus 

    if [[ "$didWGUp" -eq 1 ]]; then
        WGDown
    fi
}

Main
exit 0

