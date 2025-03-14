function [bits_window_out, z1_window_out, z2_window_out, metric_survivors_out, state_out, depth_out, full_window_flag_out] = viterbi_algorithm(metrics, bits_window_same_index, z1, z1_window_same_index, z2, z2_window_same_index, depth, bits_window_depth, metric_survivors_same_index, state)
% ignoring the simulation delay caused by the downconverter filter plus
% delay
if depth < 1
    bits_window_out = bits_window_same_index;
    z1_window_out = z1_window_same_index;
    z2_window_out = z2_window_same_index;
    metric_survivors_out = metric_survivors_same_index;
    state_out = state;
    depth_out = depth + 1;
    full_window_flag_out = false;
else
    double_state = double(state); % starting state = 0 if even, 1 if odd
    index_state = 2 - double_state; % 2 if even starting state, 1 if odd starting state
    
    metric_transition_same_index = metrics(:, index_state, index_state);
    metric_transition_different_index = circshift(metrics(:, 3-index_state, index_state),(-1)^(1-double_state)); % case double_state is even(double_state=0), shift up the array to select the previous sample. Case double_state is odd(double_state=1), shift down the array to select the next sample
    metric_survivors_different_index  = circshift(metric_survivors_same_index,(-1)^(1-double_state));
    bits_window_different_index = circshift(bits_window_same_index , (-1)^(1-double_state), 1);
    z1_window_different_index= circshift(z1_window_same_index, (-1)^(1-double_state), 1);
    z2_window_different_index= circshift(z2_window_same_index, (-1)^(1-double_state), 1);
    
    total_metric_same_index      = metric_survivors_same_index      + metric_transition_same_index;
    total_metric_different_index = metric_survivors_different_index + metric_transition_different_index;
    
    bits_window_out = bits_window_same_index;
    z1_window_out= z1_window_same_index;
    z2_window_out= z2_window_same_index;
    metric_survivors_out = metric_survivors_same_index;
    for i = 1:size(metrics,1)
        if total_metric_same_index(i) > total_metric_different_index(i) % if double_state=1, a comparision is made between the current states and the previous one. If double_state=0, a comparasion is made between the current double_state and the next one
            % same index win
            bits_window_out(i,depth) = 1 - double_state;
            z1_window_out(i,depth)= z1(index_state);
            z2_window_out(i,depth)= z2(index_state);
            
            metric_survivors_out(i) = total_metric_same_index(i);
            % For (double_state=)odd-even transition, the same index wins implies that bit 0 has been sent
            % For (double_state=)even-odd transition, the same index wins implies that bit 1 has been sent
        else
            % different index wins
            bits_window_out(i,:) = bits_window_different_index(i,:); % bits path merge
            z1_window_out(i,:)= z1_window_different_index(i,:); % z1 path merge
            z2_window_out(i,:)= z2_window_different_index(i,:); % z2 path merge
            
            bits_window_out(i,depth) = double_state;
            z1_window_out(i,depth)= z1(3-index_state);
            z2_window_out(i,depth)= z2(3-index_state);
            
            metric_survivors_out(i) = total_metric_different_index(i);
            % For (double_state=)odd-even transition, the different index wins implies that bit 1 has been sent
            % For (double_state=)even-odd transition, the different index wins implies that bit 0 has been sent
        end
    end
    state_out = not(state);
    
    if depth < bits_window_depth
        depth_out = depth + 1;
        full_window_flag_out = false;
    else
        depth_out = depth;
        full_window_flag_out = true;
    end
end

end