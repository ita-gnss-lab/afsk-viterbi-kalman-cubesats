% Transform BER_per_scenario into a .csv file
% we only consider the BER for Monte Carlo runs that managed to acquire the
% signal. Regarding the loss of lock, instead, count how many occurs for
% each sat_namexEbN0 and save it in another .csv to obtain a heatmap.

load outputs/BER_dB.mat BER_per_scenario

%% proposed model with impairments
sat_names = string(BER_per_scenario.keys);

% get all Eb/N0 values found appeared in the sat names (with no repetition)
EbN0s_dB = [];
for sat_name = sat_names
    EbN0s_dB = [EbN0s_dB, cell2mat(BER_per_scenario(sat_name).per_EbN0_dB.keys)];
end
EbN0s_dB = unique(EbN0s_dB);

% ignore "none" and "dummy"
sat_names = sat_names(sat_names~="none" & sat_names~="dummy");

% x/y value of the BER
xy_values = containers.Map(num2cell(EbN0s_dB), NaN(length(EbN0s_dB),1));

loss_of_lock = containers.Map;
for sat_name=sat_names
    loss_of_lock(sat_name) = struct('EbN0_dB', ...
        containers.Map(EbN0s_dB, zeros(1, length(EbN0s_dB))));
end

for EbN0_dB=EbN0s_dB
    mean_EbN0s_dB = [];
    all_sats = [];
    for sat_name=sat_names
        if ~isKey(BER_per_scenario(sat_name).per_EbN0_dB, EbN0_dB)
            % this sat does not have any simulation for this Eb/N0 value,
            % skip it
            continue
        else
            per_monte_carlo_run = BER_per_scenario(sat_name).per_EbN0_dB(EbN0_dB);
            % NOTE: after iterating over all sat_names, you can see the BER
            % obtained of all sats for a given Eb/N0
            all_sats = [all_sats per_monte_carlo_run];
            % NOTE: we need to do it because MATLAB does not more than
            % one level indexing
            this_lock = loss_of_lock(sat_name);
            this_lock.EbN0_dB(EbN0_dB) = sum(per_monte_carlo_run > 0.4);
            loss_of_lock(sat_name) = this_lock;
            %
            mean_EbN0s_dB = [mean_EbN0s_dB mean(per_monte_carlo_run(per_monte_carlo_run < 0.4))];
        end
    end
    xy_values(EbN0_dB) = mean(mean_EbN0s_dB);
end

BER_table = array2table([cell2mat(xy_values.values).' cell2mat(xy_values.keys).'], ...
    'VariableNames', ["mean_BER" "EbN0_dB"]);

writetable(BER_table, 'outputs/csv/BER_proposed.csv');


%% save loss of lock rate

% Eb/N0
for sat_name = sat_names
    EbN0s_dB = [EbN0s_dB, cell2mat(BER_per_scenario(sat_name).per_EbN0_dB.keys)];
end
EbN0s_dB = unique(EbN0s_dB);

data = {};
for sat_name = sat_names
    data = [data; loss_of_lock(sat_name).EbN0_dB.values];
end

table_data = ["sat_name|Eb/N0" EbN0s_dB;
               sat_names.' string(data)];

writecell(cellstr(table_data), "outputs/csv/loss_of_lock_rate.csv");

%% proposed model without impairments

% filter out those Eb/N0 that doesn't contain BER for scenarion with on
% impairments
EbN0s_dB_no_imp = EbN0s_dB(ismember(EbN0s_dB, cell2mat(BER_per_scenario("none").per_EbN0_dB.keys)));

% x/y value
xy_values = containers.Map(num2cell(EbN0s_dB_no_imp), NaN(length(EbN0s_dB_no_imp),1));

for EbN0_dB=EbN0s_dB_no_imp
    mean_EbN0s_dB = [];
    per_monte_carlo_run = BER_per_scenario("none").per_EbN0_dB(EbN0_dB);
    mean_EbN0s_dB = [mean_EbN0s_dB mean(per_monte_carlo_run)];
    xy_values(EbN0_dB) = mean(mean_EbN0s_dB);
end

BER_table = array2table([cell2mat(xy_values.values).' cell2mat(xy_values.keys).'], ...
    'VariableNames', ["mean_BER" "EbN0_dB"]);

writetable(BER_table, 'outputs/csv/BER_proposed_no_impairments.csv');


%% Theorical upper bound
delta_f = 1000; % Hz
fd = delta_f/2; % Frequency deviation
Tb = 1/1200;
h = 2*fd*Tb; % Indice de modulação (h=5/6)
EbN0s = 10.^(EbN0s_dB/10);
Ns = 400;

n = (1:Ns);
d_B2 = 2 - 1/Ns*sum(cos(2*pi*h*n/Ns)) - 1/Ns*sum(cos(2*pi*h - 2*pi*h*n/Ns)); % equals to d_B = 2*(1 - sinc(2*h))
coherent_upper_bound = 2*qfunc(sqrt(d_B2*EbN0s));

BER_table = array2table([coherent_upper_bound.' EbN0s_dB.'], ...
    'VariableNames', ["mean_BER" "EbN0_dB"]);
writetable(BER_table, 'outputs/csv/BER_upperbound.csv');

%% Theorical Noncoherent AFSK
fc = 120e3;
delta_f = 1000; % Hz
f0 = fc-(delta_f/2);
f1 = fc+(delta_f/2);


cc = @(f0,f1,t) cos(2*pi*f0*t).*cos(2*pi*f1*t);
I = integral(@(t) cc(f0,f1,t),0,Tb);
abs_ro = abs(2*I/Tb);
a = sqrt( (EbN0s/2) .* (1 - sqrt(1-abs_ro^2) ) );
b = sqrt( (EbN0s/2) .* (1 + sqrt(1-abs_ro^2) ) );
Q = marcumq(a,b);
Bessel = besselj(0, EbN0s*abs_ro/2);

error_prob_noncoherent = Q - 1/2.*exp(-EbN0s/2).*Bessel;

BER_table = array2table([error_prob_noncoherent.' EbN0s_dB.'], ...
    'VariableNames', ["mean_BER" "EbN0_dB"]);

writetable(BER_table, 'outputs/csv/BER_noncoherent.csv');