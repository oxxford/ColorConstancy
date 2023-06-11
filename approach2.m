munsell = load('./data/munsell380_800_1.mat'); % Munsell spectra used for training
c_v_eigen = load('./data/basis_func8_munsell_SVD.mat');
% this is the basis variable
c_v_eigen = c_v_eigen.c_v_eigen;

% Culling Extraneous Data and Converting to Array
MacBeth_r=readtable('./data/MacbethColorChecker.xls');
% here only 400-700nm
MacBeth_r=table2array(MacBeth_r(6:66,2:25));
% to use 19 patches (as the network predicts)
MacBeth_r(:, 19:20) = [];
MacBeth_r(:, 20:22) = [];

rgb_cmf=load('./data/rgb_cmf.mat');
rgb_cmf=rgb_cmf.tmp(5:65, 2:4); % here only 400-700nm

% probes are something that the basis will be multiplied on (r*cmf)
probes = [MacBeth_r.*rgb_cmf(:, 1), MacBeth_r.*rgb_cmf(:, 2), MacBeth_r.*rgb_cmf(:, 3)];
munsell = munsell.munsell(21:5:321,:);

% DATA FROM THE NETWORK+GT
[RGBs_preds, RGBs_gt, spds_gt] = read_test_data( ...
    './data/_Test_chartCV_3000ep_2.csv', ...
    './data/_Pred_chartCV_3000ep_2.csv', ...
    './data/image2spd_name_Samsung.csv', ...
    './data/SPDs/');
spds_gt = spds_gt(5:65, :); % here only use 400-700nm

% DATA FROM THE CAMERA
% [RGBs_gt, spds_gt] = read_gt_data('image2spd_name_Samsung.csv', './RGB_xy_samsung/', '../../SPDs/');
% spds_gt = spds_gt(5:65, :); % here only 400-700nm
% % to use 19 patches (as the network predicts), comment to use all 24
% RGBs_gt(19:20, :, :) = [];
% RGBs_gt(20:22, :, :) = [];

%%%%%%%%%%%%%% The next 6 lines introduces the new basis, excluding these
%%%%%%%%%%%%%% lines will lead to the the method of part et al (ICCV 2007)
response = munsell'*probes;
W = munsell * response * inv(response'*response + 0.* eye(size(probes,2)));
munsellrec = W*response';
[U S V] = svd(munsell);
eigenvect = U(:,1:8);
c_v_eigen = eigenvect;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calling a function to convert RGB_c to RGB_r
% 61 stands for spectral values range: 81 for 380-780, 61 for 400-700
% true/false stands for whether to use only 19 values (as the network predicts)
% RGBs_r = RGB_c2RGB_r(RGBs_gt, 61, true);
RGBs_r = RGB_c2RGB_r(RGBs_preds, 61, true);

spds_predicted = zeros(61, size(spds_gt, 2));
sam_avg = 0;
for index=1:size(RGBs_r, 3)
    spd = spds_gt(:, index);   
    
    options = optimset('Algorithm','interior-point-convex','LargeScale','off','MaxIter',1000);
    
    alpha = 3.5; % Regularization Param
    
    F = probes' * c_v_eigen;

    % predicting from the RGBs that came from camera/network
    RGB_r = RGBs_r(:, :, index);
    I = reshape(RGB_r, 1, size(RGB_r, 1)*size(RGB_r, 2));

    % predicting from the ground truth RGBs
%     I = spd'*probes;

    A = c_v_eigen;

    for m = 1: size(A,2)
        t(:,m) = diff(A(:,m));
        B(:,m) = diff(t(:,m));
    end
    
    F = [F' alpha.*B']';
    I = [I zeros(1,59)];
    
    H = 2.*F'* F;
    f = 2 * F' * I';
    
    [sigma, fval] = quadprog(H,-f',-A,zeros(1,61),[],[],[],[],[],options);
    
    recon_spec = sum(repmat(sigma',61,1) .* c_v_eigen,2);
    spds_predicted(:, index) = recon_spec;
    s = sam(spd, recon_spec);
    sam_avg = sam_avg + s;
end

hold on;
for i=1:size(spds_predicted, 2)
    % plot normalized predicted spds
    plot(spds_predicted(:, i) / sqrt(dot(spds_predicted(:, i), spds_predicted(:, i))));
end
fprintf('\n Sam %f \n', sam_avg/size(spds_predicted, 2))
