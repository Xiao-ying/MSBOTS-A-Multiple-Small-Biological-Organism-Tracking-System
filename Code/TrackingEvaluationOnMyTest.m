% no parameter to change but only select the two folders of the ground
% truth and the tracking results by myTesing (which do the tracking for the segmentation result images)
% by change the start point of "for loop" in line 93, you can choose the range of frames to evaluate 
clear;
close all;
% Function handle to check intersection with ROI
% within_roi_fx = @is_in_roi_groundplane;

% Function handle to compute the score matrix for Munkre's algorithm
score_fx = @score_matrix_euclidean;

% Distance threshold on score matrix to consider a mapping to be valid
acceptance_threshold = 50; % Allow a maximum distance of 0.5 [m]

%% Load groundtruth and hypotheses
fprintf('Please select the tracking ground truth MAT file\n')
% MatFolder=uigetdir;
MatFolder1='C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\03\VideoFrame';
load(fullfile(MatFolder1,'CentroidLocation.mat'))
N_object=size(pts{1,1},2);
N_frames = size(pts,2);
temp2 = cell2mat(pts);
groundtruths = cell(1,N_object);
for i = 1:N_object
groundtruths{1,i}.obj_id = i-1;
positions = nan(N_frames,3);
positions( : ,1 ) = [1 : N_frames];
positions( : ,2 ) = temp2(1, i:N_object:end );
positions( : ,3 ) = temp2(2, i:N_object:end );
groundtruths{1,i}.positions = positions;
end

%% Load hypotheses
fprintf('Please select the tracking result folder by myTesting\n')
% MatFolder=uigetdir;
MatFolder = 'C:\Users\xiaoy\Google Drive\MoreOrganism\Daphnia\Proposed\03\StrenthedSegResults';

load(fullfile(MatFolder,'hypotheses_all_connect.mat'))
if  exist('hypotheses_all')==0
hypotheses_all = hypotheses_all_connect;
end
% for the sequence 1
% load('Segm5Seq3\hypotheses_all.mat');

% for sequnce 2
% load('C:\Users\xiaoy\Google Drive\ProposedZebrafishDataset\02\hypotheses_all.mat')

% Prepare storage arrays
true_positives_total = zeros(1, length(N_frames)); % c_t (found/correct matches at time t)
false_positives_total = zeros(1, length(N_frames)); % tracker identifies too much/drifts, etc
false_negatives_total = zeros(1, length(N_frames)); % tracker misses a objects
id_switches_total = zeros(1, length(N_frames)); % tracker switches trajectories (mismatches)
num_objects_total = zeros(1, length(N_frames)); % number of objects present (groundtruth) at time t
sum_distances_total = zeros(1, length(N_frames)); % sum_i d^i_t (for each frame, holds the sum of the distances)

% Get threshold value, pick as the maximu value of the distance in ground
% truth *1.2

for ii = 1 : size(groundtruths,2)

 diff_groundtruth = diff(groundtruths{1,ii}.positions);
 distance = sqrt(sum(diff_groundtruth.^2,2)-1);
 max_distance = max(distance);
if acceptance_threshold < max_distance
    acceptance_threshold = max_distance * 1.2;
end
end

%% Process each (annotated) frame
idx = 1;
previous_mapping = {};
for frame = 1 : N_frames
  %% Grab groundtruth/annotations for current frame
%   [ groundtruth, hypotheses ] = load_for_frame( frame, groundtruths, hypotheses_all, score_fx, acceptance_threshold, roi, within_roi_fx );
%  load ground truth
gidx = 1;
    groundtruth = {};
  for i = 1:length(groundtruths)
  gt_o = groundtruths{i};
  found = find(gt_o.positions(:,1) == frame);
  if any(found)
    position = gt_o.positions(found, 2:end);
      obj.obj_id = gt_o.obj_id;
      obj.position = position;
       groundtruth{gidx} = obj;
      gidx = gidx + 1;
  end
  end
%  load hyphothses, i.e. the tracking result by a tracker
   hidx = 1;
   hypotheses = {};
  for i = 1:length(hypotheses_all)
   h_o = hypotheses_all{i};
  if isempty(h_o)
    continue
  end
  
  found = find(h_o.positions(:,1) == frame);
  if any(found)
    position = h_o.positions(found, 2:end);
      obj.obj_id = h_o.obj_id;
      obj.position = position;
          hypotheses{hidx} = obj;
      hidx = hidx + 1;
  end
   end
  %% Build score matrix
  score_matrix = score_fx(groundtruth, hypotheses);
  num_objects = length(groundtruth);
  
  %% Step 1, check if previous mapping is still valid
  [ current_mapping, previous_mapping, groundtruth, hypotheses ] = verify_previous_mapping(previous_mapping, groundtruth, hypotheses, score_matrix, acceptance_threshold);
  % Remaining groundtruth objects/hypothesis may have changed
  score_matrix = score_fx(groundtruth, hypotheses);
  
  
  %% Step 2, assign hypotheses to unmatched objects (uses Munkre's algorithm)
  [ current_mapping, previous_mapping, groundtruth, hypotheses, id_switches ] = find_matching_hypotheses(previous_mapping, current_mapping, groundtruth, hypotheses, score_matrix, acceptance_threshold);
  % Remaining groundtruth objects/hypothesis may have changed
  score_matrix = score_fx(groundtruth, hypotheses);
  % Now, a complete set of matching pairs for the current frame is known...
   
  
  %% Step 3, true matches + distances of these for the current frame
  true_positives = length(current_mapping);
  sum_distances = sum_matching_scores(current_mapping);
  
  
  %% Step 4, false positives and misses
  % Remaining hypotheses are false positives
  false_positives = length(hypotheses);
  % Remaining objects (groundtruth) are misses/false negatives
  false_negatives = length(groundtruth);
   
  
  %% Store computed metrics for current frame
  true_positives_total(idx) = true_positives;
  false_positives_total(idx) = false_positives;
  false_negatives_total(idx) = false_negatives;
  id_switches_total(idx) = id_switches;
  num_objects_total(idx) = num_objects;
  sum_distances_total(idx) = sum_distances;
  
  
  %% Prepare next iteration
  idx = idx + 1;
  % Keep previous mappings to handle re-identification errors
  idx_cm = length(current_mapping) + 1;
  for i = 1:length(previous_mapping)
    current_mapping{idx_cm} = previous_mapping{i};
    idx_cm = idx_cm + 1;
  end
  
  previous_mapping = current_mapping;
end

%% Compute tracker metrics
num_objects = sum(num_objects_total(:));
num_true_positives = sum(true_positives_total);
num_misses = sum(false_negatives_total(:));
num_false_positives = sum(false_positives_total(:));
num_id_switches = sum(id_switches_total(:));
motp = sum(sum_distances_total(:)) / num_true_positives;
miss_ratio = num_misses / num_objects;
false_positive_ratio = num_false_positives / num_objects;
mismatch_ratio = num_id_switches / num_objects;
mota = max(0, 1 - (miss_ratio + false_positive_ratio + mismatch_ratio));
mota_min = min(0, 1 - (miss_ratio + false_positive_ratio + mismatch_ratio));
% Display results
fprintf('\nResults\n');
fprintf('  TP:                            %d\n', num_true_positives);
fprintf('  FP:                            %d\n', num_false_positives);
fprintf('  FN (misses):                   %d\n', num_misses);
fprintf('  ID switches (mismatches):      %d\n', num_id_switches);
fprintf('  Miss ratio:                    %f\n', miss_ratio);
fprintf('  FP ratio:                      %f\n', false_positive_ratio);
fprintf('  Mismatch ratio (ID switches):  %f\n', mismatch_ratio);
fprintf('  MOTP:                          %.3f [pixels]\n', round(motp*1e3)/1e3);
fprintf('  MOTA:                          %.3f\n', round(mota*1e3)/1e3);
mota_min

