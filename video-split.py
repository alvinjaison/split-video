from moviepy.editor import VideoFileClip

def split_video(filename, segment_length=9):
    clip = VideoFileClip(filename)
    total_duration = clip.duration
    segment_count = int(total_duration // segment_length)

    for i in range(segment_count):
        start_time = i * segment_length
        end_time = min((i + 1) * segment_length, total_duration)
        segment = clip.subclip(start_time, end_time)
        segment.write_videofile(f"segment_{i+1}.mov", codec="rawvideo")

    # Process the remaining part if any
    if end_time < total_duration:
        remaining_segment = clip.subclip(end_time, total_duration)
        remaining_segment.write_videofile(f"segment_{segment_count + 1}.mov", codec="rawvideo")

    clip.close()

# Usage
split_video("./input_video.mov")
