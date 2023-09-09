function [RGBW] = RGBtoRGBW(RGBs, mode)

% Takes the RGB Triplets for Macbeth and Normalize them for White Light
% (Equalizing Color Channels of Grey and Applying same Transform all RGB)
% RGBs are the Triplet as an Array
% Mode Specifies Type of Normalization
    % Mode=0 Channels are Equalized to Average of Channels
    % Mode=1 Channels are Equalized to G (Retain Lightness)

% Splitting Grey Triplet (22nd index) into R, G, and B Components
% R=RGBs(21,1);
% G=RGBs(21,2);
% B=RGBs(21,3);

% alternative: 19th value since only 19 values arrive from the network
R=RGBs(19,1);
G=RGBs(19,2);
B=RGBs(19,3);

% If Statement to Store Transform Equalizing to Average of RGB (Mode=0)
if mode==0
    avg=(R+G+B)/3;
    transform=[avg/R, 0, 0;
               0, avg/G, 0;
               0, 0 ,avg/B];
end
% If Statement to Store Transform Equalizing to G (Mode=1) of Grey
if mode==1
    transform=[G/R, 0, 0;
               0, 1, 0;
               0, 0, G/B];
end

% Multiplying RGBs by same Transform as above to Simulate White Light for
% all Chromaticies
RGBW=RGBs*transform;

% Above Transform may Push White Patch RGB>255, Need to Normalize so
% Maximum RGB (White Patch) =255,255,255
% 19 is Index of White Patch
R_W=RGBW(19,1);
G_W=RGBW(19,2);
B_W=RGBW(19,3);

% alternative: use the maximum value of each attribute
% R_W=max(RGBW(:,1));
% G_W=max(RGBW(:,2));
% B_W=max(RGBW(:,3));
transform_norm=[255/R_W, 0, 0;
                0, 255/G_W, 0;
                0, 0, 255/B_W];

% Applying Normalization to Entire RGB Set so White RGB=255,255,255
RGBW=RGBW*transform_norm;
end