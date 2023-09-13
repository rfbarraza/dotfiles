#!/usr/bin/env zsh

{
    sh_header -n "Wayside Report" -d "Server Status and Logs"
    sake -c ~/.config/sake/wysd/sake.yaml run ping;
    sake -c ~/.config/sake/wysd/sake.yaml run info;
    echo "\n\n"
    echo "# ###################################################################"
    echo "# Docker"
    echo "# ###################################################################\n"
    sake -c ~/.config/sake/wysd/sake.yaml run docker-status;
    echo "\n\n"
    echo "# ###################################################################"
    echo "# Call Attendant"
    echo "# ###################################################################\n"
    sake -c ~/.config/sake/wysd/sake.yaml run phone-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phonecalls;
    echo "\n\n"
    echo "# ###################################################################"
    echo "# E-Mail"
    echo "# ###################################################################\n"
    sake -c ~/.config/sake/wysd/sake.yaml run dads-email;
} | sed 's/\[[0-9;]*m//g' | sed 's/\[0;1m//g' > ~/Documents/Family/Wayside/Status/sake-report-$(date +%Y-%m-%d).txt

