function [FDnew,QDnew] = get_discrete_wiener(L,M,T,sigma,delta)
% Project File: LOS.m

% Author: Rodrigo de Lima Florindo

% Version: 1.1

% Date: 24/10/2024

% Description: This code may be used to generate the state transition
% matrix and noise covariance matrix of the LOS dynamics for a generic
% multi-frequency system using the development proposed in section 2.1. of
% my ION GNSS+ 2024 paper. The mathematical development shown in this paper
% is overlooked in most of papers of this theme.

% Args:
% L - Number of carriers to be included on the state space model
%
% M - Order of the Wiener process
%
% T - Sampling Time
% 
% sigma - Vector whose elements are the variances of each sub-covariance
% matrix. For instance, for L = 1 and M = 3, the true covariance matrix is
% composed by three "sub" covariance matrices, which have the following
% format (You can see these matrices debugging the code and displaying QDi):
% QDi(:,:,1) =
% 
% [T_I*s1, 0, 0]
% [     0, 0, 0]
% [     0, 0, 0]
% 
% 
% QDi(:,:,2) =
% 
% [(4*T_I^3*d1^2*s2*pi^2)/3, pi*T_I^2*d1*s2, 0]
% [          pi*T_I^2*d1*s2,         T_I*s2, 0]
% [                       0,              0, 0]
% 
% 
% QDi(:,:,3) =
% 
% [(T_I^5*d1^2*s3*pi^2)/5, (pi*T_I^4*d1*s3)/4, (pi*T_I^3*d1*s3)/3]
% [    (pi*T_I^4*d1*s3)/4,       (T_I^3*s3)/3,       (T_I^2*s3)/2]
% [    (pi*T_I^3*d1*s3)/3,       (T_I^2*s3)/2,             T_I*s3].
%
% The values of each "sub"covariance matrix has a common term denoted by
% s1, s2 and s3, respectively. These values are the variances related to 
% clock noise from the receiver and satellite, as well as uncertainties 
% about the receiver-satellite relative motion. In general, the last 
% QDi(:,:,end) matrix is related to the relative motion uncertainty, 
% while the other matrices are the ones related to the clock noise 
% (please, refer to  Friederieke Fohlmeister Thesis section 2.4 
% for further developments).
%
% delta - Vector whose elements values are the frequency of each carrier
% divided by the reference carrier (Ex: suppose L1, L2 and L5 multi-fre-
% quency carrier tracking. delta is given by 
% delta = [f_L1/f_L1, f_L2/f_L1, f_L5/f_L1]. For single frequency carrier
% phase tracking, input delta as 1.)

% Returns:
% FDnew: State transition matrix.
% QDnew: Noise Covariance Matrix.

    % T_I: integration period
    % tau: continuous-time integration variable
    syms T_I tau real
    % s: variances of Q_\xi (contious covariance matrix)
    syms s [M+L-1 1] real
    % d: delta  factor that relates a reference carrier with the other
    % carriers (see Eq. (9))
    syms d [L,1] real

    Aux1 = sym(ones(L-1,1));
    for i=1:(L-1)
        Aux1(i,1) = 2*pi*d(i);
    end

    % cf. eq (9)
    F1 = sym([zeros(L-1,1),Aux1,zeros(L-1,M-2)]);
    
    % cf. eq (9)
    F2 = sym([[zeros(M-1,1),eye(M-1)];zeros(1,M)]);
    F2(1,2) = 2*pi*(d(L));

    % cf. eq (7)
    Fw = sym([[zeros(L-1,L-1),F1];[zeros(M,L-1),F2]]);

    % cf. eq (11)
    FD = sym(zeros(M+L-1));
    for j=0:(M-1)
        FD = FD + ((Fw*T_I)^(j))/factorial(j);
    end

    %% Calculate the covariance QD
    % each frontal in the Qxi_i corresponds to one of the subcovariances of
    % Q_xi
    Qxi_i = sym(zeros(L+M-1,L+M-1,L+M-1));
    for i=1:(M+L-1)
        Qxi_i(i,i,i) = s(i);
    end
    
    % E is the e^{Fw(T_I-\tau)} (see eq. (15) and (16))
    E = sym(zeros(M+L-1));
    for j=0:(M-1)
        E = E + ((Fw*(T_I-tau))^(j))/factorial(j);
    end

    % each value of QDi is the result of the integral (see eq. (16))
    QDi = sym(zeros(L+M-1,L+M-1,L+M-1));
    % QD is the summation of all QDi's (see eq. (16))
    QD = sym(zeros(L+M-1));
    for i = 1:(M+L-1)
        expr = E * Qxi_i(:,:,i) * E';
        QDi(:,:,i) = int(expr,tau,0,T_I); % solve the integral
        QD = QD + QDi(:,:,i);
    end

    %% Substitution the values of T_I, s and d on FD and QD
    FDnew = FD; % Initialize FDnew
    for i = 1:length(d)
        FDnew = subs(FDnew, d(i), delta(i)); % Substitute each element of d with corresponding delta
    end

    FDnew = subs(FDnew, T_I, T);
    FDnew = double(FDnew);

    QDnew = QD; % Initialize FDnew
    for i = 1:length(d)
        QDnew = subs(QDnew, d(i), delta(i)); % Substitute each element of d with corresponding delta
    end

    for i = 1:length(sigma)
        QDnew = subs(QDnew, s(i), sigma(i)); % Substitute each element of d with corresponding delta
    end

    % Substitute T_I
    QDnew = subs(QDnew, T_I, T);
    QDnew = double(QDnew);
end