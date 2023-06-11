name2spdname_filename = './data/image2spd_name_Samsung.csv';
RGBs_path = './data/RGB_xy_samsung/';
spds_path = './data/SPDs/';

[RGBs_gt, spds_gt] = read_gt_data(name2spdname_filename, RGBs_path, spds_path);
% to use 19 patches (as the network predicts), comment to use all 24
RGBs_gt(19:20, :, :) = [];
RGBs_gt(20:22, :, :) = [];

lspdds = get_lspdds('./data/lspdd.json', true); % true stands for SPD normalization

% generate RGB values for lspdds spd set
RGB_lspdds = Spectra_to_Macbeth_values(lspdds, 'RGB');
% to use 19 patches (as the network predicts), comment to use all 24
RGB_lspdds(19:20, :, :) = [];
RGB_lspdds(20:22, :, :) = [];

% "train" pseudoinverse to convert RGB_r values to spd
% on the lspdd data
m = lspdds * pinv(reshape(RGB_lspdds, ...
    size(RGB_lspdds, 1)*size(RGB_lspdds, 2), size(RGB_lspdds, 3)));

% calling a function to convert RGB_c to RGB_r
% 81 stands for spectral values range: 81 for 380-780, 61 for 400-700
% true/false stands for whether to use 19 values (as the network predicts)
RGBs_r = RGB_c2RGB_r(RGBs_gt, 81, true);

% use this to predict SPDs using the pseudoinverse
spds_predicted = m*reshape(RGBs_r, ...
    size(RGBs_r, 1) * size(RGBs_r, 2), size(RGBs_r, 3));

% calculate average SAM and visualize
sam_avg = 0;
hold on;
for j=1:size(spds_predicted, 2)
    sam_avg = sam_avg + sam(spds_gt(:, j), spds_predicted(:, j));
    plot(spds_predicted(:, j) / sqrt(dot(spds_predicted(:, j), spds_predicted(:, j))))
end
fprintf('\n Sam average %f \n', sam_avg/size(spds_predicted, 2))