% get real satellite orbits from `scintpy`
scenarios = get_scenarios();

f_uplink = 149e6;
Tb = 1/1200;

max_size = 0;
for scenario=scenarios
    [phi_LOS, ~] = get_LOS_effects(f_uplink, scenario, 1);
    
    f_D = diff(phi_LOS.Data) / (phi_LOS.Time(2)-phi_LOS.Time(1));
    f_D_dot = diff(phi_LOS.Data, 2) / (phi_LOS.Time(2)-phi_LOS.Time(1))^2;

    LOS_table = array2table([phi_LOS.Data(3:end) f_D(2:end) f_D_dot phi_LOS.Time(3:end)], ...
        'VariableNames', ["phi_LOS", "f_D", "f_D_dot", "time"]);

    writetable(LOS_table, ['outputs/csv/' ...
    char(replace(scenario.sat_name, [" " "-"], "_")) ...
    '_LOS.csv']);

    if length(phi_LOS.Time) > max_size
        time = phi_LOS.Time;
    end
end