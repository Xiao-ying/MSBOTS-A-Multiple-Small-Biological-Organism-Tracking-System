% create region segmentation image from idTracker results
% First select the segm directory which produced by running idTracker
% Load all the segm_*.mat variable
  SegmFolder=uigetdir;
  [parentdir,~,~]=fileparts(SegmFolder);
  mkdir(fullfile(parentdir,'SegmMasks'));
% Check how many segm_*.mat results exist  
  SegmList = dir(strcat(SegmFolder,'\segm_*.mat'));
  [N M] = size(SegmList.name);
  if N == 1
      Segm =  load (fullfile(SegmFolder,'segm_1.mat'));
      VideoLength = size(Segm.variable);
      %  abtract video size 
      VideoInfo = load(fullfile(SegmFolder,'datosegm.mat'));
      FrameSize = VideoInfo.variable.tam;

      % Create region segmentation mask from idTracker results
      for i = 1:VideoLength(2)
          SegmMaskName = sprintf('SegmMask%02d.png', i);
          SegmMask = zeros(FrameSize);
          ObjectN = numel(Segm.variable(i).pixels);
          for j = 1: ObjectN
              SegmMask(Segm.variable(i).pixels{1,j})=1;  
          end
         imwrite(SegmMask,fullfile(parentdir,'SegmMasks',SegmMaskName));
      end 
  else
      disp('More than 1000 frames detected, so segm data are seperated to segm_*.mat')
  end
  
  disp('program finished')