function [xkk1, k, xkk, Pkk, ik] = KF_PLL(k,xk1k1,Pk1k1,zk,Fk,Qk,Rk,Hk,theta_s_int)
% Project Title: KF_PLL
% Author: Rodrigo de Lima Florindo
% Version: 1.0
% Date: 14/10/2024
% Description: This code run a KF algorithm for a proposed state space
% model.
% Inputs:
% - xkk: x̂[k|k], state variable using knowledge of the statistics at k.
% - Pkk: P[k|k], covariance matrix of the state variables.
% - Fk: F[k], transition matrix of the state variables.
% - Qk: Q[k], covariance matrix noise of the state variable.
% - Rk: R[k], covariance matrix noise of the observations.
% - Hk: H[k], transition matrix of the observations.
% - theta_s_int: phase memory.
% Outputs:
% - xkk1: x̂[k|k-1], the predicted states using knowledge of the statistics
% at k-1.
%% Prediction
if k == 1
    xkk1 = xk1k1;
    Pkk1 = Pk1k1;
    k=2;
else
    xkk1 = Fk*xk1k1;
    Pkk1 = Fk*Pk1k1*Fk' + Qk;
end

%% Atualization

% Innovation
% remove the modulation phase memory
zk_no_mem = zk * exp(-1j*theta_s_int);
% compensate the phase offset caused by the transitory behavior of the
% filtering during downconversion. This value can be assessed by analyzing
% difference between the phase of the baseband signal at the modulator and
% the phase of the output filter at downconverter. You should take into
% consider that the received signal is delayed by Tb.
zk_no_mem = zk_no_mem * exp(+1j*2.432);

ik = atan(imag(zk_no_mem)/real(zk_no_mem));
fprintf(['ik is %f and ' ...
         'zk_no_mem is %f%+fj\n'], ...
         ik, ...
         real(zk_no_mem), ...
         imag(zk_no_mem));

% Kalman gain
Kk = Pkk1*Hk.'*((Hk*Pkk1*Hk.' + Rk)\1);
% state variable update
xkk = xkk1 + Kk.*ik;
% state variables error covariance matrix update
Pkk = Pkk1 - Kk*Hk*Pkk1;
end