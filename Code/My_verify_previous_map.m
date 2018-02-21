function [ cur_map, prev_map, gt, hyp ] = My_verify_previous_map( previous_mapping, groundtruth, hypotheses, score_matrix, threshold )
%VERIFY_PREVIOUS_MAPPING Performs step 1 of the mapping procedure
% Verifies if previous mappings (o_i, h_j) are still valid, i.e., the
% object is still visible and the hypotheses are still mapped to the same
% groundtruths
% 
%  previous_mapping
%    Cell array of mappings (groundtruth to hypothesis) from the previous
%    time step
%  groundtruth 
%    Groundtruth annotations for current frame
%  hypotheses 
%    Tracking results for current frame
%  score_matrix 
%    Distance matrix, where rows correspond to groundtruth objects and
%    columns correspond to hypotheses
%  threshold 
%    Maximum distance on score_matrix values to consider a mapping valid

% We return altered previous and current mappings
cur_map = {};
prev_map = {};
% Indices into the returned mappings
idx_cm = 1; 
idx_pm = 1;
% List of assigned obj IDs
mapped_gt_ids = [];
mapped_hyp_ids = [];

%% Try to establish correspondences
for i = 1:length(previous_mapping)
  mapping = previous_mapping{i};
  gt_idx = find_obj(groundtruth, mapping.gt_id);
  hyp_idx = find_obj(hypotheses, mapping.hyp_id);
  
  % If gt and hypotheses are visible in the current frame...
  if gt_idx > 0 && hyp_idx > 0
    % ... check their distance
    score = score_matrix(gt_idx, hyp_idx);
    if score < threshold
      % Make the correspondence for the current frame too
      mapping.score = score;
      cur_map{idx_cm} = mapping;
      idx_cm = idx_cm + 1;
      % We will have to remove them from the current groundtruth/hypotheses
      mapped_gt_ids = [mapped_gt_ids, mapping.gt_id];
      mapped_hyp_ids = [mapped_hyp_ids, mapping.hyp_id];
    else
      % The tracker drifted, so we cannot establish the correspondence
      prev_map{idx_pm} = mapping;
      idx_pm = idx_pm + 1;
    end
  else
    % Could not verify the current mapping, so keep it in the prev_map
    prev_map{idx_pm} = mapping;
    idx_pm = idx_pm + 1;
  end
end

%% Remove assigned mappings from current groundtruth/hypotheses
% s.t. they will not interfer with further steps of the
% evaluation/assignment
gt = {};
gt_idx = 1;
for i = 1:length(groundtruth)
  g = groundtruth{i};
  if ~any(mapped_gt_ids == g.obj_id)
    gt{gt_idx} = g;
    gt_idx = gt_idx + 1;
  end
end
hyp = {};
hyp_idx = 1;
for i = 1:length(hypotheses)
  h = hypotheses{i};
  if ~any(mapped_hyp_ids == h.obj_id)
    hyp{hyp_idx} = h;
    hyp_idx = hyp_idx + 1;
  end
end
end

% Returns the idx into the cell array objects (either groundtruth or
% hypotheses) which belongs to the struct of the given object ID
% Returns -1 if no object was found
function [idx] = find_obj(objects, id)
idx = -1;
for oidx = 1:length(objects)
  o = objects{oidx};
  if o.obj_id == id
    idx = oidx;
    break;
  end
end
end


