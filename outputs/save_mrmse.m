load outputs/RMSE_trace.mat RMSE_fD_dot_per_scenario RMSE_fD_per_scenario trace_per_scenario

for sat_name=RMSE_fD_per_scenario.keys
    % sampled value of RMSE_fD
    RMSE_fD_table = array2table([reshape(RMSE_fD_per_scenario(sat_name{1}).per_montecarlo_run.Data(1:1000:end), [], 1) ...
        RMSE_fD_per_scenario(sat_name{1}).per_montecarlo_run.Time(1:1000:end)], ...
        'VariableNames', ["RMSE_fD", "time"]);
    writetable(RMSE_fD_table, ['outputs/csv/' ...
        char(replace(sat_name{1}, [" " "-"], "_")) '_RMSE_fD.csv']);

    % sampled value of RMSE_fD_dot
    RMSE_fD_dot_table = array2table([reshape(RMSE_fD_dot_per_scenario(sat_name{1}).per_montecarlo_run.Data(1:1000:end), [], 1) ...
        RMSE_fD_dot_per_scenario(sat_name{1}).per_montecarlo_run.Time(1:1000:end)], ...
        'VariableNames', ["RMSE_fD", "time"]);
    writetable(RMSE_fD_dot_table, ['outputs/csv/' ...
        char(replace(sat_name{1}, [" " "-"], "_")) '_RMSE_fD_dot.csv']);
end