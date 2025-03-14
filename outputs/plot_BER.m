% Plot the BER performance for:
% 1. Noncoherent demodulation
% 2. Coherent demodulation with synchronism impairments
% 3. Coherent demodulation without any synchronism impairment
% 4. Theoretical upper bound for the case 3.
%% Initial parameters
addpath './outputs' % Unix-like path
load BER_dB.mat Eb_N0_dB BER_no_impairments BER_with_impairments
if bdIsLoaded('AFSK')
    % If the sysyem is alredy open, close it to load `PreloeadFnc`.
    % `1` is set to salve the model before closing it. Choose `0` to
    % the opposite
    close_system('AFSK.slx', 1);
end
load_system('AFSK.slx'); % load the model (PreloeadFnc)
Eb_N0 = 10.^(Eb_N0_dB/10);
h = 5/6;

%% 1. Theorical Noncoherent AFSK

cc = @(f0,f1,t) cos(2*pi*f0*t).*cos(2*pi*f1*t);
I = integral(@(t) cc(f0,f1,t),0,Tb);
abs_ro = abs(2*I/Tb);
a = sqrt( (Eb_N0/2) .* (1 - sqrt(1-abs_ro^2) ) );
b = sqrt( (Eb_N0/2) .* (1 + sqrt(1-abs_ro^2) ) );
Q = marcumq(a,b);
Bessel = besselj(0, Eb_N0*abs_ro/2);

error_prob_noncoherent = Q - 1/2.*exp(-Eb_N0/2).*Bessel;
% Pb_theo_nc = marcumq(0, sqrt(Eb_No)) - 1/2.*exp(-Eb_No/2).*besselj(0, 0); % Caso ortogonal

figure(1)
semilogy(Eb_N0_dB, error_prob_noncoherent, 'LineWidth', 4, 'color','red','MarkerSize', 10);
legend('Theoretical noncoherent AFSK');

%% 2. Coherent without impairments + its theoterical upper bound
hold on
semilogy(Eb_N0_dB, BER_no_impairments,'--*','LineWidth', 2, 'color', 'black', 'MarkerSize', 15);
legend('Proposed model (no impairments)');

% Theorical upper bound
n = (1:Ns);
d_B2 = 2 - 1/Ns*sum(cos(2*pi*h*n/Ns)) - 1/Ns*sum(cos(2*pi*h - 2*pi*h*n/Ns)); % equals to d_B = 2*(1 - sinc(2*h))
coherent_upper_bound = 2*qfunc(sqrt(d_B2*Eb_N0));

semilogy(Eb_N0_dB, coherent_upper_bound,'LineWidth', 4,'color', 'black');
legend('Theoretical upper bound');

%% Coherent with impairments
semilogy(Eb_N0_dB, BER_with_impairments, 'Marker', 'd', 'MarkerSize', 10, 'LineWidth', 4);
legend('Proposed model (with impairments)');

%% Labels, title, color, and axes
legend('location','southwest', 'FontName', 'Times New Roman');
% legend({'Proposed model (no impairments)', 'Theoretical upper bound', 'Theoretical noncoherent AFSK', '25 kHz'}, 'location','southwest', 'FontName', 'Times New Roman');
set(gcf,'Color','White');
set(gca,'Xgrid','on','Ygrid','on', 'FontSize', 40, 'FontName', 'Times New Roman', 'XTick', 0:1:15); % , 'TickLabelInterpreter','latex'
xlabel('$E_b/N_0$     ', 'Interpreter', 'latex', 'FontName', 'Times New Roman');
ylabel('BER','FontName', 'Times New Roman'); % ,'Interpreter', 'latex'
set(gca,'FontName','Times New Roman');