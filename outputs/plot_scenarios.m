addpath ./inputs

scenarios = get_scenarios();

f_uplink = 149e6;

% get the maximum number of samples for all scenarios (the number os
% samples in each scenarios may vary)
max_size = max(arrayfun(@(x) length(x.time_sec), scenarios));

[azimuth_deg, altitude_deg, phi_LOSs, f_Ds, f_D_dots] = deal(NaN(max_size, numel(scenarios)));
for i=1:numel(scenarios)
    [phi_LOS, ~] = get_LOS_effects( ...
        f_uplink, ...
        scenarios(i), ...
        scenarios(i).time_sec(2)); % NOTE: the very same sampling time is passed as we don't want interpolation

    f_D = diff(phi_LOS.Data);
    f_D_dot = diff(f_D);

    azimuth_deg_ = (180/pi)*double(scenarios(i).sat_orbit.azimuth_rad);
    azimuth_deg(1:length(azimuth_deg_), i) = azimuth_deg_;
    
    altitude_deg_ = double(scenarios(i).sat_orbit.altitude_deg);
    altitude_deg(1:length(altitude_deg_), i) = altitude_deg_;
    
    phi_LOSs(1:length(phi_LOS.Data), i) = phi_LOS.Data;
    f_Ds(1:length(f_D), i) = f_D;
    f_D_dots(1:length(f_D_dot), i) = f_D_dot;
end

%Skyplot
fig = figure;
cmap = parula(numel(scenarios));
skyplot( ...
    azimuth_deg, ...
    altitude_deg, ...
    GroupData=categorical([scenarios.sat_name]), ...
    Color=cmap, ...
    MaskElevation=5, ...
    MarkerSizeData=200);
legend(scenarios.sat_name);

% subplot(2,2,2);
% plot(phi_LOSs);
% subplot(2,2,3);
% plot(f_Ds);
% subplot(2,2,4);
% plot(f_D_dots);
% hold off