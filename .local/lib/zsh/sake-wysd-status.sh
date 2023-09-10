#!/usr/bin/env zsh

{
    sake -c ~/.config/sake/wysd/sake.yaml run ping;
    sake -c ~/.config/sake/wysd/sake.yaml run info;
    sake -c ~/.config/sake/wysd/sake.yaml run docker-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phone-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phonecalls;
} | sed 's/\[[0-9;]*m//g' | sed 's/\[0;1m//g' > ~/Desktop/sake-wysd-report.txt
