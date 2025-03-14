function impulse_response = get_matched_filter_impulse_response(Tsamp, Tb, Ns, h)
% Get the impulse response of the baseband matched filter bank
% Input parameters:
%
% - Ns: Number of samples per bit.
% - Tb: Bit time.
% - Tsamp: Sampling time.
% - h: modulation index
%
% Output:
% - impulse_response [2 x Ns]: The impulse response for the filter bank,
% where the first and second position if for the bit -1 and 1,
% respectively.

phase_pulse = [-linspace(Tsamp / (2*Tb),0.5,Ns).' linspace(Tsamp / (2*Tb),0.5,Ns)'];
impulse_response = exp(1j*2*pi*h*phase_pulse);
end