% get real satellite orbits from `scintpy`
scenarios = get_scenarios();

% export azimuth and zenith angles to .csv per satellite to be used on Tikz
for i = 1:numel(scenarios)
    azimuth_deg = (180/pi)*double(scenarios(i).sat_orbit.azimuth_rad).';
    zenith_deg = 90 - double(scenarios(i).sat_orbit.altitude_deg).';

    azi_zen_table = array2table([azimuth_deg zenith_deg], ...
        'VariableNames', ["azimuth", "zenith"]);

    writetable(azi_zen_table, ['outputs/csv/' ...
                char(replace(scenarios(i).sat_name, [" " "-"], "_")) '.csv']);
end