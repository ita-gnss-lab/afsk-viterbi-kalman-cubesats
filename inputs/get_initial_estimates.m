function initial_estimates = get_initial_estimates(phi_LOS, Tb)
%% compute fd
% numerical differentiation of phi_LOS (normalized by 2pi)
init_fd_1 = (phi_LOS(2,:)-phi_LOS(1,:))/(2*pi*Tb);
init_fd_2 = (phi_LOS(3,:)-phi_LOS(2,:))/(2*pi*Tb);

%% compute fd dot
% numerical differentiation of fd
init_fd_dot = (init_fd_2-init_fd_1)/Tb;

initial_estimates = [phi_LOS(1,:);init_fd_1;init_fd_dot];
end

