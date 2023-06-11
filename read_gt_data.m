% This function reads the RGB values from the mat files, that were
% generated while cropping the images 
% It partially copies read_test_data function, but I don't know how to
% optimize it
function [RGBs, spds]=read_gt_data( ...
    name2spdname_filename, ... % 'image2spd_name_Samsung.csv'
    RGBs_path, ... % './RGB_xy_samsung/'
    spds_path ... % '../../SPDs/'
    )
    name2spdname = readtable(name2spdname_filename, Delimiter=';');

    RGBs = zeros(24, 3, height(name2spdname));
    spds = zeros(81, height(name2spdname));
    wv = linspace(380, 780, 81);

    for r=1:height(name2spdname)
        % process and store rgbs
        filename = char(name2spdname(r, 1).names);
        datapath = strcat(RGBs_path, 'RGB_xy', filename(1:length(filename) - 4), '.mat');
        data = load(datapath);
    
        RGBs(:, :, r) = data.xy_RGB(:, 3:5);
    
        % make spds
        curr_spd = char(name2spdname(r, 2).SPD);
    
        % maybe necessary to replace delimeter to ',' check the file
        spd = readtable(strcat(spds_path, curr_spd), Delimiter=',');
        curr_index = 1;
        for j=1:height(spd)
            v = spd(j, 1);
            
            % if the current wavelength match with those that we want to
            % store - put it in the storage on the current index and
            % increment the index for storage
            if ismember(char(v.MODEL), wv)
                spds(curr_index, r) = double(spd(j, 2).SV15x1);
                curr_index = curr_index + 1;
            end
        end
        
    end
end