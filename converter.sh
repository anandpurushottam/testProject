#!/bin/bash

# Take input file -----------------------------------------------------

INPUT_FILE=$1

if [ ! "$INPUT_FILE" ];then
   echo "Specify a valid input without mp4 extension"
   echo "Syntax:\n./converter.sh input_file_name"  
   echo "Enter a mp4 file without extension "
   echo "e.g. if file name is input_file_name.mp4 enter input_file_name"   
   exit 0
fi
   echo INPUT_FILE

# Set Quality -----------------------------------------------------------

GOPSIZE=180
#QUALITIES=(25 30 40 50)

QUALITIES=(25)

# exec related config ----------------------------------------------------

BENTO_BIN_DIR="/home/ec2-user/node/nodewebservice/Bento4/bin"
BENTO_SCRIPT_DIR="/home/ec2-user/node/nodewebservice/Bento4/utils"

# Clean up previous run --------------------------------------------------

rm $INPUT_FILE-*
rm -r output

# Generate mp4 files with closed GOPs in different qualities --------------
for quality in ${QUALITIES[@]};
do
  ffmpeg -i $INPUT_FILE.mp4 -strict experimental -deinterlace -vcodec h264 -acodec aac  -crf $quality $INPUT_FILE-$quality.mp4
done

# Fragment mp4 files -------------------------------------------------------
for quality in ${QUALITIES[@]};
do
  $BENTO_BIN_DIR/mp4fragment --fragment-duration 6 $INPUT_FILE-$quality.mp4 $INPUT_FILE-$quality-fragmented.mp4
done

# Call mp4-dash.py ---------------------------------------------------------
MEDIA_SOURCES=""
for quality in ${QUALITIES[@]};
do
  MEDIA_SOURCES="$MEDIA_SOURCES $INPUT_FILE-$quality-fragmented.mp4"
done
$BENTO_SCRIPT_DIR/mp4-dash.py --exec-dir $BENTO_BIN_DIR $MEDIA_SOURCES

# Delete files --------------------------------------------------------------
for quality in ${QUALITIES[@]};
do
   rm $INPUT_FILE-$quality-fragmented.mp4
   rm $INPUT_FILE-$quality.mp4
done

# Rename output folder ------------------------------------------------------
  mv output $INPUT_FILE  

# Sync output files ---------------------------------------------------------
 
  aws s3 sync --region ap-south-1 $PWD/$INPUT_FILE s3://video-output-server/video/$INPUT_FILE

# delete output files -------------------------------------------------------
  rm -r $INPUT_FILE



