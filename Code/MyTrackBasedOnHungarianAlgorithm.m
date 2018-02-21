% manually input parameters: SegmFolder
% N_objects = 5; 
SegmFolder = 'C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\Proposed\05\StrenthedSegResults';
% SegmFolder = 'C:\Users\xiaoy\Google Drive\ProposedZebrafishDataset\01\StrenthedSegResultsSegmStrenth6_2\ElipsFitted';
% SegmFolder = 'C:\Users\xiaoy\Google Drive\ProposedZebrafishDataset\05\StrenthedSegResults';
SegmList = dir(strcat(SegmFolder,'\StrImg*.png'));

%% Obtain the centroid points
% updated way of obtaining the centroid points after Post-processing step
% saved the 'points' variable to replace line 13 - 30
load(fullfile(SegmFolder,'points.mat'))

 n_frames = length(SegmList);
% points = cell(n_frames, 1);
% 
% for i_frame = 1: n_frames
%   Iname = fullfile(SegmFolder,sprintf('StrImg%02d.png',i_frame));
% frame = imread(Iname);
% % properties =  regionprops(frame,'basic');
% % n_object = length(properties);
% % if n_object > N_objects
% %     
% %  points{i_frame}  = regionprops(frame,'centroid');
% % end
% temp  = struct2cell(regionprops(frame,'centroid'));
% temp2 = cell2mat(temp);
% points{i_frame}( 1, : ) = temp2(1, 1:2:end );
% points{i_frame}( 2, : ) = temp2(1, 2:2:end );
% points{i_frame} = points{i_frame}';
% end

%% Plot the random points
% We plot a 'x' at each point location, and an index of the frame they are
% in next to the mark.

figure(1)
clf
hold on
for i_frame = 1 : n_frames
   
    str = num2str(i_frame);
    for j_point = 1 : size(points{i_frame}, 1)
       pos  = points{i_frame}(j_point, :);
        plot(pos(1), pos(2), 'x')
%         text('Position', pos, 'String', str)
    end
    
end

%% Track them
% Finally! A one liner. We add some information to the output, and allow
% gap closing to happen all the way through.

max_linking_distance = 400;
max_gap_closing = Inf;
debug = true;

[ tracks adjacency_tracks A n_cells] = simpletracker(points,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...  
    'Debug', debug);

%% Plot tracks
% We want to plot each track in a given color. Normally we would have to
% retrieve the points coordinates in the given |points| initiall cell
% arrat, for each point in frame. To skip this, we simple use the
% adjacency_tracks, that can pick points directly in the concatenated
% points array |all_points|.

n_tracks = numel(tracks);
colors = hsv(n_tracks);

all_points = vertcat(points{:});

for i_track = 1 : n_tracks
   
    % We use the a    djacency tracks to retrieve the points coordinates. It
    % saves us a loop.
    
    track = adjacency_tracks{i_track};
    track_points = all_points(track, :);
    
%     2D plot
%     plot(track_points(:,1), track_points(:, 2), 'Color', colors(i_track, :))
%  3D plot   
      plot3(track_points(:,1), track_points(:, 2), [1:length(track_points(:, 2))],'Color', colors(i_track, :))
    
end

%% Save tracking results
N_track = size(adjacency_tracks,1);
hypotheses_all = cell(1,N_track);

% Input the corresponding object from tracking result to tracking ground
% truth: i_track =   ; hypotheses_all{1,1}.obj_id
% i_track = [3, 4, 5 ,2];

j = 0;
for i = 1: N_track
     
track = adjacency_tracks{i};
track_points = all_points(track, :);

track_frame_index = nan(numel(track),1);
     for j2 = 1 : numel(track)            
            cell_index = track(j2);            
            % We must determine the frame this index belong to
            tmp = cell_index;
            frame_index = 1;
            while tmp > 0
                tmp = tmp - n_cells(frame_index);
                frame_index = frame_index + 1;
            end
            frame_index = frame_index - 1;
            track_frame_index(j2) = frame_index;
            
     end
     
hypotheses_all{1,j+1}.obj_id = j;
positions = nan(length(track),3);
positions( : ,1 ) = track_frame_index;
positions( : ,2 ) = track_points( : ,1);
positions( : ,3 ) = track_points( : ,2);
hypotheses_all{1,j+1}.positions = positions;
j = j+1;
end

filename = fullfile(SegmFolder,'hypotheses_all.mat');
save (filename , 'hypotheses_all')
disp(' Program finished')

%%

% %% Save tracking results
% N_track = size(adjacency_tracks,1);
% hypotheses_all = cell(1,N_track);
% 
% % Input the corresponding object from tracking result to tracking ground
% % truth: i_track =   ; hypotheses_all{1,1}.obj_id
% i_track = [3, 4, 5 ,2];
% 
% j = 0;
% for i = i_track
%      
% track = adjacency_tracks{i};
% track_points = all_points(track, :);
% 
% track_frame_index = nan(numel(track),1);
%      for j2 = 1 : numel(track)            
%             cell_index = track(j2);            
%             % We must determine the frame this index belong to
%             tmp = cell_index;
%             frame_index = 1;
%             while tmp > 0
%                 tmp = tmp - n_cells(frame_index);
%                 frame_index = frame_index + 1;
%             end
%             frame_index = frame_index - 1;
%             track_frame_index(j2) = frame_index;
%             
%      end
%      
% hypotheses_all{1,j+1}.obj_id = j;
% positions = nan(length(track),3);
% positions( : ,1 ) = track_frame_index;
% positions( : ,2 ) = track_points( : ,1);
% positions( : ,3 ) = track_points( : ,2);
% hypotheses_all{1,j+1}.positions = positions;
% j = j+1;
% end
% 
% % Get extra tracking left in the tracking results
% N_left = N_track - length(i_track);
% extra_track = nan(1,N_left);
% extra_index = 1;
% for i = 1: N_track
%     if isempty(find(i_track == i))
%        extra_track(extra_index) = i;
%        extra_index = extra_index + 1;
%     end 
% end
% 
% for i = extra_track
%         track = adjacency_tracks{i};
% track_points = all_points(track, :);
% 
% track_frame_index = nan(numel(track),1);
%      for j1 = 1 : numel(track)            
%             cell_index = track(j1);            
%             % We must determine the frame this index belong to
%             tmp = cell_index;
%             frame_index = 1;
%             while tmp > 0
%                 tmp = tmp - n_cells(frame_index);
%                 frame_index = frame_index + 1;
%             end
%             frame_index = frame_index - 1;
%             track_frame_index(j1) = frame_index;
%             
%      end
% 
% hypotheses_all{1,j+1}.obj_id = j;
% positions = nan(length(track),3);
% positions( : ,1 ) = track_frame_index;
% positions( : ,2 ) = track_points( : ,1);
% positions( : ,3 ) = track_points( : ,2);
% hypotheses_all{1,j+1}.positions = positions;
% j = j+1;
% end
% 
% filename = fullfile(SegmFolder,'hypotheses_all.mat');
% save (filename , 'hypotheses_all')

%%
% Jean-Yves Tinevez <jeanyves.tinevez@gmail.com> November 2011 - May 2012

