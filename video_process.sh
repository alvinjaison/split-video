#!/bin/bash

# Default values
video_url=""
output_name="output"
segment_length=9

# Function to display usage
usage() {
    echo "Usage: $0 -u <YouTube_URL> -n <output_name> [-l <segment_length>]"
    echo "Options:"
    echo "  -u <YouTube_URL>: YouTube video URL"
    echo "  -n <output_name>: Desired name for the saved video"
    echo "  -l <segment_length>: Length of each segment in seconds (default: 9)"
    exit 1
}

# Parse command-line options
while getopts ":u:n:l:" opt; do
    case $opt in
        u)
            video_url="$OPTARG"
            ;;
        n)
            output_name="$OPTARG"
            ;;
        l)
            segment_length="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check if required options are provided
if [ -z "$video_url" ]; then
    echo "Error: YouTube URL is missing." >&2
    usage
fi

# Download the video using yt-dlp
echo "Downloading video..."
yt-dlp -f 'bestvideo[height<=2160][ext=mp4][vcodec!=none]+bestaudio[ext=m4a]/best[height<=2160][ext=mp4]/best[ext=mp4]' "$video_url" -o "$output_name.mp4"

# Convert the downloaded video to MOV format
echo "Converting video to MOV format..."
ffmpeg -i "$output_name.mp4" -c:v h264 -c:a aac -strict -2 "$output_name.mov"

# Split the video into segments of the accepted time length
echo "Splitting video into segments..."
ffmpeg -i "$output_name.mov" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 192k -force_key_frames "expr:gte(t,n_forced*$segment_length)" -map 0 -segment_time "$segment_length" -segment_format_options movflags=+faststart -reset_timestamps 1 -f segment "${output_name}_segment%03d.mp4"

echo "Video splitting completed."

exit 0
