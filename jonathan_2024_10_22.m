clear; clc;

% ========== The only portion that needs to be adjusted by user for new files ==========
% Fill in additional file info
SUBJECT = 'Jonathan';
DATE = '2024_10_22';
TASK = 'Isometric Extension Ramp 1';
FILE_DESCRIPTION = "Jonathan 2024-10-22: Isometric Extension Ramp 1 10s, UP 10s, HOLD 10s, DOWN 10s, REST";% custom file description

% Define full file path and pass in to the reader...
%fname = "C:/example/path/to/IsometricFlexionRamp_1_241022_150834/IsometricFlexionRamp_241022_150834.rhd";
%x = io.read_Intan_RHD2000_file(fname);
x = io.read_Intan_RHD2000_file();              % ... or call up the GUI to select the file.

% ======================================================================================

% Let's parse out the data
sample_rate = x.frequency_parameters.amplifier_sample_rate;
t = x.t_amplifier;
sync = -x.board_adc_data;
aux = rms(x.aux_input_data(1:3,:)-median(x.aux_input_data(1:3,:),2),1);
% The auxiliary input for the RHD chips is actually 3 channels with a
% separate sampling rate, have to account for and combine to one channel
fs_aux = x.frequency_parameters.aux_input_sample_rate;
[b,a] = butter(3,1/(fs_aux/2),'low');
aux = 1e3.*interp1(1:numel(aux),filtfilt(b,a,aux),linspace(1,numel(aux),(sample_rate / fs_aux)*numel(aux)));

% We can apply a high-pass filter to the HDEMG channel data
[b,a] = butter(3,100/(sample_rate/2),'high');
uni = filtfilt(b,a,x.amplifier_data')';

% Arrangement of channels is important so the order needs to be reordered.
% Based on HDEMG-128ch-v16 channel layout, 8x8 order of channels 1:64 need
% to be transposed. Same transpose applied to 65:128.
uni(1:64,:) = reshape(gradient(reshape(uni(1:64,:),8,8,[])),64,[]);     
uni(65:128,:) = reshape(gradient(reshape(uni(65:128,:),8,8,[])),64,[]);

%% Sanity-checking full traces.
fig = figure('Color','w','Name',FILE_DESCRIPTION,'Units','inches','Position',[1 1 8 6],...
    'WindowState','maximized');
cdata = [winter(64); spring(64)];
ax = axes(fig,'NextPlot','add','XLim',t([1,end]),'ColorOrder', cdata,  ...
    'YTick', [-1000, 3000, 9000, 14000], ...
    'YTickLabel', ["Torque (a.u.)", sprintf("\\color[rgb]{%.2f,%.2f,%.2f}Extensors",cdata(32,:)), sprintf("\\color[rgb]{%.2f,%.2f,%.2f}Flexors",cdata(96,:)), "\color[rgb]{0.65,0.65,0.65}Accelerometer RMS (a.u.)"]);
plot(ax, t, uni' + (0:100:(100*127)));

plot(ax, t, sync.*450 - 1500, 'Color', 'k', 'DisplayName', 'Torque');
plot(ax, t, aux.*500 + (100*130), 'Color', [0.65 0.65 0.65], 'DisplayName', 'Accelerometer RMS');
title(ax, FILE_DESCRIPTION, 'FontName','Tahoma','Color','k');

% Save figure to export directory
export_dir = fullfile(pwd, 'export', sprintf('%s_%s', SUBJECT, DATE));
utils.save_figure(fig, export_dir, sprintf('%s--Full-Traces', TASK), 'ExportAs', {'.png'}, 'SaveFigure', false);

%% Export data for DEMUSE
mat_file = sprintf('%s_%s_%s.mat', SUBJECT, DATE, TASK);
save(fullfile(export_dir, mat_file),'uni','sample_rate','FILE_DESCRIPTION','sync','aux','-v7.3');
fprintf(1,'Export complete: %s\n', utils.print_windows_folder_link(export_dir, mat_file));

%% After running the processing with DEMUSE, get the .mat output file and make sure it contains the 
