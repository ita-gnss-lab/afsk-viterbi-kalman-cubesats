function [Px_0_0,x00_matrix,Fk,Qk,Hk,Rk] = get_kf_intial_cfg(EbN0, M, Tb, sigma2_process, x_00, init_LOS_delay)
% Get initial configuration parameters of the Kalman filter

% Author: Rodrigo de Lima Florindo

% Version: 1.0

% Date: 19/07/2024

% Description: This code may be used to generate the initial configurations
% of the EKF for each topology.

% Its output are:
% 1 - The full initial error covariance matrix - Px_0_0; 
% 2 - The initial States - x_hat_0_0;
% 3 - the full process noise covariance matrix - Qk;
% 4 - the full process state transition matrix - Fk;

% Intialize Kalman Filter Parameters

% covariance matrix of the measurements. In our case, we have only one
% measurement and therefore Rk =  \sigma_v^2 is a scalar.
%cf. Friederieke Thesis equation 3.228; It is assumed here That EbN0=SNR.
Rk = 10^(-EbN0/10); 

% Measurement model transition matrix.
Hk = [1,zeros(1,M-1)];

%Initialization Matrices
doppler_init_covariance = zeros(1,(M));
doppler_init_covariance(1) = pi^2/3;
doppler_init_covariance(2) = 0.1^2/12;
doppler_init_covariance(3) = 0.01^2/12;
%doppler_init_covariance(4) = 0.001^2/12;

[Fk,Qk] = get_discrete_wiener(1,M,Tb,sigma2_process,1);
Px_0_0 = diag(doppler_init_covariance); % Initial Error Covariance Matrix

% x00_matrix is used to initialize the Kalman filter states. Since it is
% necessary to wait the convergence of the veterbi algorithm to start the
% propagation and update steps of the Kalman filter, it was considered here
% that the first 26 initial samples were estimated considering only the
% propagation step based on an initial guess of Doppler shift (f_D) and
% Doppler drift (f_D_dot).

% Each columns of x00_matrix correspond to the firsts {1,2,...,26} samples,
% considering zeros indexing, of the initial states guesses. A sample was 
% estimated in advance to compensate for the delay in interpolation
% inside the carrier generator block. This makes easier to evaluate if
% there is an initial error in the phase estimation. Each row of this
% matrix corresponds to each state. We could improve this part to be more
% straightforward later.
x00_matrix = zeros(3,25 + init_LOS_delay + 1);
x00_matrix(:,1) = x_00;
for i = 2:25 + init_LOS_delay + 2
    x00_matrix(:,i) = Fk*x00_matrix(:,i-1);
end
x00_matrix = x00_matrix(:,2:end);
end