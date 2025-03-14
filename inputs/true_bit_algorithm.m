function [bits_window_out, x_window_out, y_window_out, state_out, depth_out, is_full_window] = true_bit_algorithm(bits_window_same_index, true_bit, x, x_window_same_index, y, y_window_same_index, depth, bits_window_depth, state)
if depth < 1
    bits_window_out = bits_window_same_index;
    x_window_out= x_window_same_index;
    y_window_out= y_window_same_index;
    state_out = state;
    depth_out = depth + 1;
    is_full_window = false;
else
    double_state = double(state); % starting state = 0 if even, 1 if odd
    index_state = 2 - double_state; % 2 if even starting state, 1 if odd starting state
    
    bits_window_different_index = circshift(bits_window_same_index , (-1)^(1-double_state), 1);
    x_window_different_index= circshift(x_window_same_index, (-1)^(1-double_state), 1);
    y_window_different_index= circshift(y_window_same_index, (-1)^(1-double_state), 1);
    
    bits_window_out = bits_window_same_index;
    x_window_out= x_window_same_index;
    y_window_out= y_window_same_index;
    
    if ((true_bit == 0) && (double_state == 1)) || ((true_bit == 1) && (double_state == 0))
        % same index win
        bits_window_out(:,depth) = 1 - double_state;
        x_window_out(:,depth)= x(index_state);
        y_window_out(:,depth)= y(index_state);
    else % ((new_bit == 1) && (double_state == 1)) || ((new_bit == 0) && (double_state == 0))
        % different index wins
        bits_window_out = bits_window_different_index; % bits path merge
        x_window_out= x_window_different_index; % x path merge
        y_window_out= y_window_different_index; % y path merge
        
        bits_window_out(:,depth) = double_state;
        x_window_out(:,depth)= x(3-index_state);
        y_window_out(:,depth)= y(3-index_state);
    end
    
    state_out = not(state);
    
    if depth < bits_window_depth
        depth_out = depth + 1;
        is_full_window = false;
    else
        depth_out = depth;
        is_full_window = true;
    end
end

end