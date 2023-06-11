function [MacBeth_values] = Spectra_to_Macbeth_values(Spectra, cmf)
    % Takes N number of Spectra and Determines either XYZ or RGB(default) Triplets for 
    % each of the 24 Color Patches of the MacBeth Checker. To get XYZ values, 
    % pass 'XYZ' as cmf argument, for RGB pass 'RGB'
    % Spectra are input as either a 81xN or 61xN array

    % Importing MacBeth Reflectivity Spectra and 1931 Standard Observer
    % Macbeth from: https://www.rit.edu/science/munsell-color-science-lab-educational-resources
    % 1931 Standard from: https://cie.co.at/datatable/cie-1931-colour-matching-functions-2-degree-observer
    MacBeth_r=readtable('./data/MacbethColorChecker.xls');
    
    [d, N] = size(Spectra);
    
    if d ~= 61 && d ~= 81
        fprintf('Incorrect spectra dimension')
    end
    
    if cmf == "XYZ"
        CMF=readtable('./data/CIE_xyz_1931_2deg.csv');
        CMF=table2array(CMF(21:5:421,2:4));
    else
        CMF=load('./data/rgb_cmf.mat');
        CMF=CMF.tmp(:, 2:4);
    end
    
    % 380 to 780 nm
    MacBeth_r=table2array(MacBeth_r(2:82,2:25));
    
    % 400 to 700 nm
    if d == 61
        MacBeth_r=MacBeth_r(5:65, :);
        CMF=CMF(5:65, :);
    end
    
    % Pre-Allocating XYZ Array Size (24 Patches, 3 Units-XYZ, N Spectra)
    MacBeth_values=zeros(24, 3, N);

    % For-loop indexing over Spectra with N variable
    for i=1:N 
        % Nested loop indexing over Patches of MacBeth with j variable
        for j=1:24
            % Solving for K constant
            K=100/sum(CMF(:,2).*Spectra(:,i));
            % Solving for each CMF with loop indexing over LMS Cones via 
            % count variable and Integrating with Spectra and MacBeth Patches
            for count=1:3
                MacBeth_values(j,count,i)=K*sum((CMF(:,count).*Spectra(:,i).*MacBeth_r(:,j)));
            end
        end
    end
end