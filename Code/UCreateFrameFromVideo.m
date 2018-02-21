% Create frames of a video and save inside the folder "VideoFrame" under
% the current folder when you run this MATLAB script.
% Replace "...\Dataset\video.avi" in the line 12: VideoFileName =
% '...\Dataset\video.avi' to the actual absolute directory of your testing
% video, including the name and extension of the video.

clear
clc

VideoFileName = 'C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\06\A011_20150716.avi';
currentFolder = pwd;
mkdir(fullfile(currentFolder,'VideoFrame'))

shuttleVideo = VideoReader(VideoFileName);
for i = 1: shuttleVideo.NumberOfFrame
img = read(shuttleVideo, i);
imwrite(img,fullfile('VideoFrame',sprintf('img%02d.jpg',i)));
end

disp('Successfully finished running the program !')