clear; clc;

description = "Kriti 2024-09-23 Tactor Pilot data";
poly5_files = {'C:/Data/Pilot/Kriti_2024_09_23/trial_7_FLX-20240923_180357.poly5'; % 
               'C:/Data/Pilot/Kriti_2024_09_23/trial_7_EXT-20240923_180357.poly5'}; 

% It looks like these files don't have any sync pulses, so we can't *truly*
% synchronize them. This is a workaround that lets us still put the samples
% together, with the understanding they might not be perfectly time-locked
% between the proximal and distal grids:
x = io.load_align_saga_data_many(poly5_files, ...
    "IsTextile64",true,...
    "ManualSyncIndex",1);

% R1C1 to R8C8 are unipolar channels
iUni = arrayfun(@(s)~isempty(regexp(s.name,'R[1-8]C[1-8]','match')),x.channels);
uni = x.samples(iUni,:);
sample_rate = x.sample_rate;
t = 0:(1/sample_rate):((size(uni,2)-1)/sample_rate);

in = load('C:\Data\Pilot\Kriti_2024_09_23\trial_7_1727129037.7519133_profiles.mat');
sync = interp1(in.time, in.force, t);
aux = interp1(in.target_profile(:,1)', in.target_profile(:,2)', t);

if exist('export/Kriti_2024_09_23','dir')==0
    mkdir('export/Kriti_2024_09_23');
end
save('export/Kriti_2024_09_23/Kriti_2024_09_23_Trial-7_synchronized.mat', ...
    'uni', 'sample_rate', 'sync', 'aux', 'description', '-v7.3');

fprintf(1,'Export complete: %s\n', ...
    utils.print_windows_folder_link(fullfile(pwd,'export','Kriti_2024_09_23'), ...
                                    'Kriti_2024_09_23_Trial-7_synchronized.mat'));