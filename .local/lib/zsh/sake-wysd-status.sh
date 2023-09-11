#!/usr/bin/env zsh

{
    sh_header -n "Wayside Report" -d "Server Status and Logs"
    sake -c ~/.config/sake/wysd/sake.yaml run ping;
    sake -c ~/.config/sake/wysd/sake.yaml run info;
    echo "\n\n"
    echo "# Docker"
    echo "# ###################################################################\n"
    sake -c ~/.config/sake/wysd/sake.yaml run docker-status;
    echo "\n\n"
    echo "# Call Attendant"
    echo "# ###################################################################\n"
    sake -c ~/.config/sake/wysd/sake.yaml run phone-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phonecalls;
} | sed 's/\[[0-9;]*m//g' | sed 's/\[0;1m//g' > ~/Desktop/sake-wysd-report.txt
