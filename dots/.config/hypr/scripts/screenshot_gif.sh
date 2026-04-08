#!/usr/bin/bash
notify-send "Gif recorder" -a "ss"

cd ~/Pictures/generated_gif
if [ -f ~/Pictures/generated_gif/recording.mkv ]; then
  rm recording.mkv
fi

wf-recorder -g "$(slurp)"

echo -n "Enter gif name:"
read FILENAME
fullFileName="${FILENAME}.gif"

ffmpeg -i recording.mkv $fullFileName
rm recording.mkv

notify-send "Gif recorded in ~/Picture/generated_gif/$fullFileName" -a "ss"
