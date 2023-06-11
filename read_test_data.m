function [predictions, ground_truths, spds]=read_test_data( ...
    test_data_filename, ... %'./_Test_chartCV_3000ep_2.csv'
    predictions_filename, ... %'./_Pred_chartCV_3000ep_2.csv'
    name2spdname_filename, ... %'image2spd_name_Samsung.csv'
    spds_path ... % '../../SPDs/'
    )
    % Returns:
    % predictions - 19x3xN_samples double array with rgb values predicted
    % ground_truths - 19x3xN_samples double array with rgb values captured
    % with a camera
    % spds - 81xN_samples double array with SPD values captured during
    % dataset acquisition using spectraradiometer

    % Test data (acquired from the photos) for 19 chromaticity pairs
    test_data=readtable(test_data_filename);
    
    % Predictions from the network of 19 chromaticity pairs
    predictions_data=readtable(predictions_filename);
    predictions_data=table2array(predictions_data);
    % remove column name
    predictions_data(1, :) = [];
    
    % File that contains the corresponding SPD file name for each image of the
    % dataset
    image_name2spd_name = readtable(name2spdname_filename, Delimiter=';');
    
    % Variables for the predictions and the spds 
    predictions = zeros(19, 3, height(test_data));
    ground_truths = zeros(19, 3, height(test_data));
    spds = zeros(81, height(test_data));
    
    % we use wavelengths from 380 to 780 nm and with a step of 5
    wvs = linspace(380, 780, 81);
    
    for row=1:height(predictions_data)
        % process and store predictions and ground truths
        predictions(:, :, row)=format_rgb_from_row(predictions_data(row, :));
    
        current_gt = test_data(row, :);
        current_gt(:, 2) = [];
        ground_truths(:, :, row)=format_rgb_from_row(table2array(current_gt));
    
        % extract spds
    
        % name of the image file
        imagefile_name = char(test_data(row, 2).id);
        % modify the image filename to extract the correpsonding spd filename
        name_formatted = strcat(imagefile_name(1:length(imagefile_name) - 12), '.tif');
        spd = zeros(81, 1);
    
        for i=1:height(image_name2spd_name)
            current_spd_filename = char(image_name2spd_name(i, 2).SPD);
    
            % if image filenames don't match - continue
            if ~strcmp(char(image_name2spd_name(i, 1).names), name_formatted)
                continue
            end
        
            % read the spd file, the file has two columns:
            % MODEL - wavelength, contains NaN before 380, stops at 1000
            % with step 1
            % SV15x1 - value for the corresponding wavelength, contains
            % trash for NaN wavelength
            spd_file = readtable(strcat(spds_path, current_spd_filename), Delimiter=',');
            
            curr_index = 1;
            for j=1:height(spd_file)
                % get the data for the current cell index
                cell = spd_file(j, 1);
    
                % if the current wavelength match with those that we want to
                % store - put it in the storage on the current index and
                % increment the index for storage
                if ismember(char(cell.MODEL), wvs)
                    spd(curr_index) = double(spd_file(j, 2).SV15x1);
                    curr_index = curr_index + 1;
                end
            end
            break
        end
    
        spds(:, row) = spd;
    end
end

function [rgb]=format_rgb_from_row(row)
    rgb = zeros(19, 3);

    for j=1:19
        r = row(2*j);
        g = row(2*j + 1);
        b = 1 - r - g;
        rgb(j, :) = [r g b];
    end
end