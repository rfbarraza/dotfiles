#!/usr/bin/env zsh

{
    sake -c ~/.config/sake/wysd/sake.yaml run ping;
    sake -c ~/.config/sake/wysd/sake.yaml run info;
    sake -c ~/.config/sake/wysd/sake.yaml run docker-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phone-status;
    sake -c ~/.config/sake/wysd/sake.yaml run phonecalls;
} > ~/Desktop/sake-wysd-report.txt
