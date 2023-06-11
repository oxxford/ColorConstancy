function [RGBs_r]=RGB_c2RGB_r(RGBs_c, spectra_d, use_nineteen)
    if spectra_d ~= 61 && spectra_d ~= 81
        fprintf('Incorrect spectra dimension')
    end
    % generate macbeth RGB values for flat, white spd
    macbeth_whites = Spectra_to_Macbeth_values(ones(spectra_d, 1), 'RGB');

    if use_nineteen
        % to use only 19 patches (as the network predicts), comment to use all 24
        macbeth_whites(19:20, :) = [];
        macbeth_whites(20:22, :) = [];
    end
    
    RGBs_w = zeros(size(RGBs_c));
    for i=1:size(RGBs_c, 3)
        RGBs_w(:, :, i) = RGBtoRGBW(RGBs_c(:, :, i), 0);
    end
    RGB_w_avg = mean(RGBs_w, 3);
    
    % predict R value from R values of all patches (B and G accordingly)
    m_c2r = macbeth_whites*pinv(RGB_w_avg);
    % predict R value from RGB triplet of a corresponding patch
    % m_c2r = macbeth_whites.'*pinv(RGB_w_avg.');
    
    RGBs_r = zeros(size(RGBs_c));
    for i=1:size(RGBs_c, 3)
        % first type of the pseudoinverse
        RGB_r = m_c2r*RGBs_c(:, :, i);
        % second type of the pseudoinverse
    %     RGB_r = m_c2r*RGBs_gt(:, :, i).';
    %     RGB_r = RGB_r.';
    
        % clipping below zero values (if needed)
        RGB_r(RGB_r < 0) = 0;
    
        RGBs_r(:, :, i) = RGB_r;
    end 

end