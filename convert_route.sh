#!/bin/bash

# Configuration
ROUTE_DIR=~/Videos/360video  # Path to the folder containing the route files
PROJECT_PATH=/home/daniel/Repositories/op-replay-clipper  # Path to the op-replay-clipper project
ROUTE_ID="00000061--3ffa4459c6"  # Your route ID without segment number
OUTPUT_DIR="$PROJECT_PATH/shared"  # Output directory for the converted video
OUTPUT_FILE="$OUTPUT_DIR/clip.equirect.mp4"  # Final output video file
RENDER_TYPE="360"  # Render type for 360 video
PREDICTION_OVERLAY="forward"  # Render type for overlaying predictions

# Set up Python environment
source "$PROJECT_PATH/../openpilot/.venv/bin/activate"

# Step 1: Convert the route to 360 video
python "$PROJECT_PATH/ffmpeg_clip.py" \
  --render_type "$RENDER_TYPE" \
  --data_dir "$ROUTE_DIR" \
  "$ROUTE_ID" \
  0 300 -nv \
  --output "$OUTPUT_FILE" \
  --format "h264"  # Add this line

# Step 2: Overlay predictions on the front camera
python "$PROJECT_PATH/ffmpeg_clip.py" \
  --render_type "$PREDICTION_OVERLAY" \
  --data_dir "$ROUTE_DIR" \
  "$ROUTE_ID" \
  0 300 -nv \
  --output "$OUTPUT_FILE" \
  --format "h264"  # Add this line

echo "360 Video: $OUTPUT_FILE"
echo "Prediction Overlay: $OUTPUT_FILE.predictions.mp4"
