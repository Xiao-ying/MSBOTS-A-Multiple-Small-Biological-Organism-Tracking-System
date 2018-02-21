clear
clc
close all

fprintf('Please select the Loli result folder by LoliTracker\n')
% LoliResFolder=uigetdir;
LoliResFolder = 'C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\01';
% [num, text, raw] = xlsread('G:\Zebrafish\ProposedSegmentationDataset\SegmentationDataset5\Fish03\video\videoForEvalu.xlsx');
[num, text, raw] = xlsread(fullfile(LoliResFolder,'videoForEvalu.xlsx'));
V = VideoReader(fullfile(LoliResFolder,'video.avi'));

%% Load groundtruth and hypotheses
fprintf('Please select the tracking ground truth MAT file\n')
% MatFolder=uigetdir;
MatFolder = 'C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\01\VideoFrame';
[OriRow, OriCol, OriLay]= size(imread(fullfile(MatFolder,'img01.jpg')));

x_ratio = V.Height/OriRow;
y_ratio = V.Width/OriCol;

N_track = (size(num,2)-2)/12;
hypotheses_all = cell(1,N_track);

% Input the corresponding object from tracking result to tracking ground
% truth: i_track =   ; hypotheses_all{1,1}.obj_id

j = 0;
for i = 1 : N_track

hypotheses_all{1,j+1}.obj_id = j;
positions = nan(size(num, 1),3);
colPosition = 6+(i-1)*12;
positions( : ,1 ) = num( : , 1);
positions( : ,2 ) = num( : ,colPosition)./x_ratio;
positions( : ,3 ) = num( : ,colPosition+1)./y_ratio;
hypotheses_all{1,j+1}.positions = positions;
j = j+1;
end

direct = fullfile(LoliResFolder,'hypotheses_all.mat');
save(direct, 'hypotheses_all')