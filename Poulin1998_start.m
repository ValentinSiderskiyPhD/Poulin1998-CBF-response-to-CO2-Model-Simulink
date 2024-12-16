close all
clc
clear 

% Parameters
PETCO2_delta = 15;
PETCO2_base = 40; % Torr or 100% ;
MCAF_base_on = 99.96;
MCAF_base_off = 102.7;
g_f_on = 2.69;
g_f_off = 2.91;
g_s = -1.26;
tau_f_on = 6.77;
tau_f_off = 14.31;
tau_s = 426.9;
Td = 3.9;

stimHzVec = [0.03125 0.0625 0.125 0.25 0.5]; % Frequencies
SR = 0.01; % Sampling rate
modelName = 'Poulin1998';

% Number of frequencies
nFreq = length(stimHzVec);

% Create a figure with a tiled layout
figure;
tiledlayout(2, nFreq, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:nFreq
    stimHz = stimHzVec(i);
    set_param(modelName, 'SimulationCommand', 'update');
    simOut = sim(modelName, ...
        'Solver', 'ode4', ...          % Choose solver (e.g., ode4 for fixed-step)
        'FixedStep', num2str(SR));    % Set the fixed step size
    outputDataset = simOut.get('yout');
    
    % Get the first signal from the dataset
    signal = outputDataset.get(1);

    % Extract time and data from the timeseries object
    time = signal.Values.Time;    % Time vector
    data = signal.Values.Data;    % Signal data
    MCAF = data(:, 1);
    ETCO2 = data(:, 2);

    % Extract the last segment of the data for this frequency
    segmentStartIdx = length(time) - round(4 / stimHz / SR);
    segmentTime = time(segmentStartIdx:end);
    segmentMCAF = MCAF(segmentStartIdx:end);
    segmentETCO2 = ETCO2(segmentStartIdx:end);

    % Normalize time for alignment
    segmentTime = segmentTime - segmentTime(1);

    % Top row: MCAF subplot
    nexttile(i); % MCAF in the first row
    plot(segmentTime, segmentMCAF, 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('MCAF');
    ylim([95, 105]); % Adjusted Y-axis limits
    xlim([segmentTime(1), segmentTime(end)]); % Tight x-axis
    title(sprintf('MCAF: %.4f Hz', stimHz));
    grid on;

    % Bottom row: ETCO2 subplot
    nexttile(i + nFreq); % ETCO2 in the second row
    plot(segmentTime, segmentETCO2, 'LineWidth', 1.5, 'Color', 'r');
    xlabel('Time (s)');
    ylabel('ETCO2');
    xlim([segmentTime(1), segmentTime(end)]); % Tight x-axis
    grid on;
end

% Add a common title for the figure
sgtitle('MCAF and ETCO2 Responses at Different Frequencies\n(Poulin et al., 1998 Model)', 'FontWeight', 'bold');

% Add a caption below the figure
annotation('textbox', [0.1, 0, 0.8, 0.05], 'String', ...
    'Data generated using the Poulin et al., 1998 model. MCAF and ETCO2 responses shown for various frequencies.', ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'EdgeColor', 'none');
