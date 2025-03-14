function [phi_LOS, tau_LOS]= get_LOS_effects(f_uplink, scenaro, Tb)
% speed of the light
c = 299792458;

%% Downsample and Interpolation
time_interp_sec = (0:Tb:scenaro.time_sec(end)-Tb).';

% interpolated true range (in km)
range_km = interp1(scenaro.time_sec,scenaro.range_km,time_interp_sec,'spline');

%% compute ϕ_LOS
% interpolated true range (in m)
range_m = range_km * 1e3;

% (1). \phi_LOS(t) = -2*pi*fc*r(t)/c (equation 2.61 from Frederieke's
% thesis)
phi_LOS = -2*pi*f_uplink*range_m/c;

%% compute tau_LOS
% (2). \tau(t) = r(t)/c, where r(t) is the pseudorange (Eq. 1.1 GNSS
% Springer)
% From (1) and (2) we can quickly derive that
% (3). \tau(t) = -\phi_LOS(t) / 2*pi*fc. (Eq. 2.10 from Frederieke's
% thesis)

tau_LOS = -phi_LOS/(2*pi*f_uplink);

%% convert to timeseries

phi_LOS = timeseries(phi_LOS, time_interp_sec);
tau_LOS = timeseries(tau_LOS, time_interp_sec);

end