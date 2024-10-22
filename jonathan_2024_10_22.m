clear; clc;

fname = "C:/Data/Pilot/Jonathan_2024_10_22/IsometricFlexionRamp_1_241022_150834/IsometricFlexionRamp_241022_150834.rhd";
x = io.read_Intan_RHD2000_file(fname);

sample_rate = x.frequency_parameters.amplifier_sample_rate;
[b,a] = butter(3,100/(sample_rate/2),'high');

uni = filtfilt(b,a,x.amplifier_data')';
uni(1:64,:) = reshape(gradient(reshape(uni(1:64,:),8,8,[])),64,[]);
uni(65:128,:) = reshape(gradient(reshape(uni(65:128,:),8,8,[])),64,[]);
t = x.t_amplifier;

sync = -x.board_adc_data;
aux = rms(x.aux_input_data(1:3,:)-median(x.aux_input_data(1:3,:),2),1);
fs_aux = x.frequency_parameters.aux_input_sample_rate;
[b,a] = butter(3,1/(fs_aux/2),'low');
aux = 1e3.*interp1(1:numel(aux),filtfilt(b,a,aux),linspace(1,numel(aux),(sample_rate / fs_aux)*numel(aux)));

description = "Jonathan Pilot 2024-10-22: Isometric Flexion Ramp 10s UP 10s HOLD 10s REST";

%% Sanity-checking full traces.
fig = figure('Color','w','Name',description,'Units','inches','Position',[1 1 8 6],...
    'WindowState','maximized');
cdata = [winter(64); spring(64)];
ax = axes(fig,'NextPlot','add','XLim',t([1,end]),'ColorOrder', cdata,  ...
    'YTick', [-1000, 3000, 9000, 14000], ...
    'YTickLabel', ["Torque (a.u.)", sprintf("\\color[rgb]{%.2f,%.2f,%.2f}Extensors",cdata(32,:)), sprintf("\\color[rgb]{%.2f,%.2f,%.2f}Flexors",cdata(96,:)), "\color[rgb]{0.65,0.65,0.65}Accelerometer RMS (a.u.)"]);
plot(ax, t, uni' + (0:100:(100*127)));

plot(ax, t, sync.*450 - 1500, 'Color', 'k', 'DisplayName', 'Torque');
plot(ax, t, aux.*500 + (100*130), 'Color', [0.65 0.65 0.65], 'DisplayName', 'Accelerometer RMS');
title(ax, description, 'FontName','Tahoma','Color','k');
utils.save_figure(fig,'export/Jonathan_2024_10_22','Isometric-Flexion-Ramp-1--Full-Traces','ExportAs',{'.png'},'SaveFigure',false);

%% Export data for DEMUSE
save('export/Jonathan_2024_10_22/Isometric-Flexion-Ramp-1.mat','uni','sample_rate','description','sync','aux','-v7.3');
fprintf(1,'Export complete: %s\n', ...
    utils.print_windows_folder_link(fullfile(pwd,'export','Jonathan_2024_10_22'), ...
                                    'Isometric-Flexion-Ramp-1.mat'));