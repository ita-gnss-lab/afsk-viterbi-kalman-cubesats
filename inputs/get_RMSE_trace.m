function get_RMSE_trace(EbN0_dB, sat_names,n_monte_carlo_runs)
%% Comments
% This code simulates the AFSK demodulator to obtain the RMSE of f_D,
% f_D_dot and the trace of the error covariance matrix.
% 
% Parameters:
% Eb_N0s_dB: Input the desired level of Eb/N0 for all simulations
% sat_names: An array of string of satellite names, or "all" if you want to
% get the RMSE for all satellites
% n_monte_carlo_runs: Input how many Monte Carlo simulations you want to
% perform.
%%
if bdIsLoaded('AFSK')
    % If the sysyem is alredy open, close it to load `PreloeadFnc`.
    % `1` is set to salve the model before closing it. Choose `0` to
    % the opposite
    close_system('AFSK.slx', 1);
end
load_system('AFSK.slx'); % load the model (PreloeadFnc)

%% Enable the Error Rate Calculation for programmatic simulation
% comment sink blocks
set_param('AFSK/Display1', 'Commented','on');
set_param('AFSK/modulator/Eye Diagram', 'Commented','on');
set_param('AFSK/modulator/Spectrum Analyzer', 'Commented','on');
set_param('AFSK/modulator/Variance', 'Commented','on');
set_param('AFSK/modulator/Display2', 'Commented','on');
% comment save variable for BER
set_param('AFSK/To Workspace BER', 'Commented','on');
% set up Error Rate Calculation
set_param('AFSK/Error Rate Calculation','Commented','on');
% uncomment AWGN channel
set_param('AFSK/AWGN Channel','Commented','off');
% unset all warnings
warning('off','all');
%% programmatically simulation settings
set_param('AFSK', 'StopTime', "tau_LOS_samples.Time(end)");
set_param('AFSK', 'SimulationMode', 'rapid-accelerator');
set_param('AFSK', 'SignalLogging', 'off');
set_param('AFSK/AWGN Channel', 'EbNodB', string(EbN0_dB));
%% handle `sat_names`
% get real satellite orbits from `scintpy`
scenarios = get_scenarios();

if ~isstring(sat_names)
    error('You must input a string array of satellite names or "all" for all satellite')
end

if sat_names == "all"
    sat_names = [scenarios.sat_name];
end

%% instantiate output stuctures
try
    load outputs/RMSE_trace.mat RMSE_fD_per_scenario RMSE_fD_dot_per_scenario trace_per_scenario
    fprintf('`BER_per_scenario` has been loaded from `outputs/BER_dB.mat`.\n');
catch exception
    RMSE_fD_per_scenario = containers.Map;
    RMSE_fD_dot_per_scenario = containers.Map;
    trace_per_scenario = containers.Map;
    fprintf('Not able to load BERs, a new BER object was created.\n');
end

%% run simulink programmatically
for sat_name=sat_names
    if ~ismember(sat_name, [scenarios.sat_name])
        error(["Error: " sat_name " is not a valid satellite name"])
    end
    % find in `sat_orbits` the index which contains `sat_name`
    j = find(strcmp([scenarios.sat_name], sat_name));
    % select the desired satellite
    scenario = scenarios(j);
    % update the base workspace with the new value of `scenario`
    % NOTE: while Simulink variables depends on the base workspace, any
    % MATLAB script is scoped in the caller workspace. Therefore, any
    % modification in the `scenario` variable is not perceived by Simulink
    % unless you bind/assign it to base workspace
    assignin('base', 'scenario', scenario);
    
    RMSE_fD_per_montecarlo_run = cell(1, n_monte_carlo_runs);
    RMSE_fD_dot_per_montecarlo_run = cell(1, n_monte_carlo_runs);
    trace_per_montecarlo_run = cell(1, n_monte_carlo_runs);
    for m = 1:n_monte_carlo_runs
        % change seed
        set_param('AFSK/Bernoulli Binary Generator', 'Seed', string(m));
        set_param('AFSK/AWGN Channel', 'Seed', string(m));

        % run
        fprintf('Running the %dth Monte Carlo simulation for satellite %s \n', m, scenario.sat_name);
        sim('AFSK');

        % save RMSE_fD
        RMSE_fD_per_montecarlo_run{m} = RMSE_f_D;
        % save RMSE_fD_dot
        RMSE_fD_dot_per_montecarlo_run{m} = RMSE_f_D_dot;
        % save trace
        trace_per_montecarlo_run{m} = tr;
    end

    RMSE_fD_per_scenario(sat_name) = struct( ...
            'EbN0_dB', EbN0_dB, ...
            'per_montecarlo_run', RMSE_fD_per_montecarlo_run);

    RMSE_fD_dot_per_scenario(sat_name) = struct( ...
            'EbN0_dB', EbN0_dB, ...
            'per_montecarlo_run', RMSE_fD_dot_per_montecarlo_run);

    trace_per_scenario(sat_name) = struct( ...
            'EbN0_dB', EbN0_dB, ...
            'per_montecarlo_run', trace_per_montecarlo_run);
end

%% Save the updated BER
save outputs/RMSE_trace.mat RMSE_fD_per_scenario RMSE_fD_dot_per_scenario trace_per_scenario
%% close the model for next iteration
close_system('AFSK.slx',1);
warning('on','all'); % set all warning to on again
end