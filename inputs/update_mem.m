function out = update_mem(theta_s_int, all_phases, bit)
% update the new init_state
index_find = find(all_phases == theta_s_int,1) - 1;
shifted = circshift(all_phases, -(index_find + 2*bit - 1));
out = shifted(1); % update θ_b to the new state
end