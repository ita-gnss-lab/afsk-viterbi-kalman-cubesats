load outputs/RMSE_trace.mat trace_per_scenario

sat_names = cellfun(@(x) string(x), trace_per_scenario.keys);
sat_names = sat_names(sat_names~="none" & sat_names~="dummy");

for sat_name=sat_names
    % sampled value of RMSE_fD
    trace_table = array2table([reshape(trace_per_scenario(sat_name).per_montecarlo_run.Data(1:2:2000), [], 1) ...
        trace_per_scenario(sat_name).per_montecarlo_run.Time(1:2:2000)], ...
        'VariableNames', ["trace", "time"]);
    
    writetable(trace_table, ['outputs/csv/' ...
        char(replace(sat_name, [" " "-"], "_")) '_trace.csv']);
end