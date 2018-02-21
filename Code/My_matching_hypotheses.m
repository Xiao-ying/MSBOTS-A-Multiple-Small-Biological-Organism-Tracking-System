function [ cur_map] = My_matching_hypotheses( groundtruth, hypotheses, score_matrix, threshold )
%FIND_MATCHING_HYPOTHESES Performs step of the mapping procedure
% this function tries to
% assign a corresponding hypothesis using Munkre's algorithm. 
% 
%  previous_mapping
%    Cell array of mappings (groundtruth to hypothesis) from the previous
%    time step
%  current_mapping
%    Valid mappings for the current time step found so far
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
% Indices into the returned mappings
idx_cm = length(cur_map) + 1; 

if length(groundtruth) > 0 && length(hypotheses) > 0
  % For all objects (groundtruth) for which no correspondence was made yet
  if length(groundtruth) > 1 || length(hypotheses) > 1
%     [assigned, cost] = assignmentallpossible(score_matrix);
   [assigned, cost] = munkres(score_matrix);
  else
    assigned = 1;
  end
  
  for gidx = 1:length(groundtruth)
    % If there are more annotated objects than hypotheses, the assignment
    % vector will contain 0 indices
    if assigned(gidx) > 0
      g = groundtruth{gidx};
      h = hypotheses{assigned(gidx)};
      score = score_matrix(gidx, assigned(gidx));
      % Only assign matching pairs with a distance score below threshold
      if score < threshold
        map.gt_id = g.obj_id;
        map.hyp_id = h.obj_id;
          % Store mapping
        map.score = score;
         cur_map{idx_cm} = map;
          idx_cm = idx_cm + 1;
      end 
    end
  end
end
      