% count the number of id switches, and also return the index i in the
% previous_mapping{i} of the id switch happens
function    [ id_switches, map_idx] = My_count_id_switches(previous_mapping, current_mapping)  
   id_switches = 0;
   map_idx = [];
   
   mapped_hyp_ids = [];
   for ind_pre = 1: length(previous_mapping)
        pre_map = previous_mapping{ind_pre};
         mapped_hyp_ids = [mapped_hyp_ids, pre_map.hyp_id];
         
   end
   
   for ind = 1: length(current_mapping)
       h = current_mapping{ind};
      
       if any(find(mapped_hyp_ids == h.hyp_id)) % the object is still visible in current map
          [pre_gt_id map_idx] = find_mapping(previous_mapping, h.hyp_id);
           if h.gt_id ~= pre_gt_id
            id_switches = id_switches + 1;
           end
          
       end
   end

end


% Returns the mapping (gt obj_id => hypothesis ID) for the given 
% groundtruth ID.
% Returns an empty list, if no mapping matches the given groundtruth ID.
function [gt_id map_idx] = find_mapping(mapping, hyp_id)
gt_id = [];
map_idx = -1;
for midx = 1:length(mapping)
  mc = mapping{midx};
  if mc.hyp_id == hyp_id
    gt_id = mc.gt_id;
    map_idx = midx;
    break;
  end
end
end
