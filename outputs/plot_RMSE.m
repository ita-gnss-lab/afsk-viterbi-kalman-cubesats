load("RMSE_trace.mat");

t = tiledlayout(1,2,'TileSpacing','compact');
nexttile;
hold on;
for RMSE_fD_=RMSE_fD
    plot(RMSE_fD_.per_montecarlo_run,'LineWidth',1);
end
legend(RMSE_fD.sat_name);
ylabel("Moving RMSE of $$f_D$$ [Hz]", 'Interpreter','latex');
xlabel("Time [sec]", 'Interpreter','latex');
hold off;

nexttile;
hold on;
for RMSE_fD_dot_ = RMSE_fD_dot
    plot(RMSE_fD_dot_.per_montecarlo_run,'LineWidth',1);
end
ylabel("Moving RMSE of $$\dot{f}_D$$ [Hz/s]", 'Interpreter','latex');
xlabel("Time [sec]", 'Interpreter','latex');
hold off;

% Define figure size in inches
width = 10;   % Width in inches
height = 5;  % Height in inches

% Set the figure properties
set(gcf, 'Units', 'inches');
% set(gcf, 'Position', [0, 0, width, height]);

% Set the paper size to match the figure size
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [width, height]);
set(gcf, 'PaperPosition', [0, 0, width, height]);
set(gcf, 'PaperPositionMode', 'manual');
print([cd,'/trace_plot'], '-dpdf', '-r300');

figure;
hold on;
% Select 2 seconds of the simulation
for trace_=trace
    plot(trace_.per_montecarlo_run,'LineWidth',1);
end
legend(RMSE_fD.sat_name);
ylabel("Trace of $$P\left[k \mid k-1 \right]$$", 'Interpreter','latex');
xlabel("Time [sec]", 'Interpreter','latex');
hold off;

% Define figure size in inches
width = 7;   % Width in inches
height = 5;  % Height in inches

% Set the figure properties
set(gcf, 'Units', 'inches');
set(gcf, 'Position', [0, 0, width, height]);

% Set the paper size to match the figure size
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [width, height]);
set(gcf, 'PaperPosition', [0, 0, width, height]);
set(gcf, 'PaperPositionMode', 'manual');