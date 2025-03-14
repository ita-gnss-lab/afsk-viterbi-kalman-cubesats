function get_BER(Eb_N0s_dB, sat_names, n_monte_carlo_runs)
% Get BER for a specific scenario and a range of Eb/N0.
%
% Description:
% This function calculates the Bit Error Rate (BER) specific scenario and a
% range of Eb/N0. The scenario might be either a real satellite-receiver
% trajectory, a dummy line-of-sight (LOS) dynamics, or with no LOS 
% dynamics, at all. In any case, a `containers.Map` is 
% generated and saved in `outputs/BER.mat`. The key of this container
% map is a string of the satellite name ("dummy" or "none" is used for
% dummy or no LOS dynamics, respectively). The value of the container map
% is a struct with a single field, `per_EbN0_dB`, which is another
% `containers.Map` whose key is the Eb/N0 in dB and value is an array with
% the BER obtained during all Monte Carlo runs.
% For example:
%   BER_per_scenario("0 AEROCUBE 8D").per_EbN0_dB(6)
%
% Input Arguments:
% - Eb_N0s_dB: A vector containing the values of the Eb/N0.
% - n_monte_carlo_runs: a scalar that sets the number of Monte Carlo runs
% for each scenario and Eb/N0 configuration.
% - sat_names: An array of string of satellite names. If it is "all", all
% available sattelites are run. If it is "dummy", dummy line-of-sight
% dynamic is considered. If it is "none", no synchronization impairment is
% considered.
%
% Author: Rubem Vasconcelos Pacelli
% Date: 11 Dec 2024
if bdIsLoaded('AFSK')
    % If the sysyem is alredy open, close it to load `PreloeadFnc`.
    % `1` is set to salve the model before closing it. Choose `0` to
    % the opposite
    close_system('AFSK.slx', 1);
end
load_system('AFSK.slx'); % load the model (PreloeadFnc)
clc;
%% Enable the Error Rate Calculation for programmatic simulation
% comment sink blocks
set_param('AFSK/modulator/Eye Diagram', 'Commented','on');
set_param('AFSK/modulator/Spectrum Analyzer', 'Commented','on');
set_param('AFSK/modulator/Variance', 'Commented','on');
set_param('AFSK/modulator/Display2', 'Commented','on');
% uncomment save variable for BER
set_param('AFSK/To Workspace BER', 'Commented','off');
% set up Error Rate Calculation
set_param('AFSK/Error Rate Calculation','Commented','off');
set_param('AFSK/Error Rate Calculation','stop', 'off');
set_param('AFSK/Error Rate Calculation','st_delay', '3.5e3');
% uncomment AWGN channel
set_param('AFSK/AWGN Channel','Commented','off');
% unset all warnings
warning('off','all');
% set phase and timing feedback systems
set_param('AFSK/Demodulator/Manual Switch','sw', '0');
set_param('AFSK/Demodulator/Manual Switch1','sw', '0');
%% programmatically simulation settings
set_param('AFSK', 'StopTime', "phi_LOS.Time(end)");
set_param('AFSK', 'SimulationMode', 'rapid-accelerator');
set_param('AFSK', 'SignalLogging', 'off');

%% handle `sat_names`
% get real satellite orbits from `scintpy`
scenarios = get_scenarios();

if ~isstring(sat_names)
    error(['You must input a string array of satellite' ...
           'names or "all" for all satellite' ])
end

if sat_names == "all"
    sat_names = [scenarios.sat_name];
end

%% load the current BER
try
    load outputs/BER_dB.mat BER_per_scenario
    fprintf('`BER_per_scenario` has been loaded from `outputs/BER_dB.mat`.\n');
catch exception
    BER_per_scenario = containers.Map;
    fprintf('Not able to load BERs, a new BER object was created.\n');
end

%% programmatic simulation
for sat_name = sat_names
    if ismember(sat_name, [scenarios.sat_name])
        is_Doppler_realistic = true;

        % find in `sat_orbits` the index which contains `sat_name`
        j = strcmp([scenarios.sat_name], sat_name);
        % select the desired satellite
        scenario = scenarios(j);

        % NOTE: while Simulink depends on variables in the base workspace,
        % any MATLAB script is scoped in the caller workspace. Therefore,
        % any modification in the `scenario` variable is not perceived
        % by Simulink unless you bind/assign it to base workspace
        assignin('base', 'scenario', scenario);

        fprintf(['*************************** ' ...
            'Starting simulation for satellite %s' ...
            ' ***************************\n\n'], sat_name);
    else
        is_Doppler_realistic = false;
        % this simulation is not based on any satellite tracjectory, set an
        % arbitrary simulation time
        set_param('AFSK', 'StopTime', "600");

        switch sat_name
            case "dummy"
                set_param('AFSK/nu', 'Value', '100');
                set_param('AFSK/nu_dot', 'Value', '10');

                fprintf(['*************************** ' ...
                    'starting for dummy LOS dynamics' ...
                    ' ***************************\n\n']);
            case "none"
                set_param('AFSK/nu', 'Value', '0');
                set_param('AFSK/nu_dot', 'Value', '0');

                % unset phase and timing feedback systems as there is no
                % impairments
                set_param('AFSK/Demodulator/Manual Switch','sw', '1');
                set_param('AFSK/Demodulator/Manual Switch1','sw', '1');

                fprintf(['*************************** ' ...
                    'starting for no LOS dynamics' ...
                    ' ***************************\n\n']);
            otherwise
                error(["Error: satellite name" sat_name ...
                    " is not a valid option"]);
        end
    end
    % assign `is_Doppler_realistic` to base workspace
    assignin('base', 'is_Doppler_realistic', is_Doppler_realistic);

    if ~isKey(BER_per_scenario, sat_name)
        % if this scenario is not instantiated. then do it
        BER_per_scenario(sat_name) = struct("per_EbN0_dB", ...
            containers.Map('KeyType', 'double', 'ValueType', 'any'));
    end
    BER_this_scenario = BER_per_scenario(sat_name);

    for Eb_N0_dB=Eb_N0s_dB
        set_param('AFSK/AWGN Channel', 'EbNodB', string(Eb_N0_dB));
        fprintf(['-> Running Eb/N0 = %d dB with ' ...
            '%d Monte Carlo simulations\n\n'], ...
            Eb_N0_dB, ...
            n_monte_carlo_runs);

        all_monte_carlo_runs = NaN(n_monte_carlo_runs, 1);
        for m=1:n_monte_carlo_runs
            % change seed
            set_param('AFSK/Bernoulli Binary Generator', 'Seed', string(m));
            set_param('AFSK/AWGN Channel', 'Seed', string(m));
            % run
            sim('AFSK');
            fprintf('Results of the %dth Monte Carlo simulation:\n', m);
            fprintf(['BER = %.4e\n' ...
                'Number of errors = %d\n' ...
                'Number of bits = %d\n\n'], ...
                BER(1), BER(2), BER(3));

            all_monte_carlo_runs(m) = BER(1);
        end
        BER_this_scenario.per_EbN0_dB(Eb_N0_dB) = all_monte_carlo_runs;
    end
    BER_per_scenario(sat_name) = BER_this_scenario;
end
%% Save the updated BER
save outputs/BER_dB.mat BER_per_scenario
%% close the model for next iteration
close_system('AFSK.slx',1);
warning('on','all'); % set all warning to on again
end