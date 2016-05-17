function [ courtImage ] = court_rgb_normalisation( courtImage )
%IMPROV_RGB_NORMALISATION Normalise RGB

Red = courtImage(:, :, 1);
Green = courtImage(:,:, 2);
Blue = courtImage(:, :, 3);

NormalizedRed = Red ./ (Red + Green + Blue);
NormalizedGreen = Green ./ (Red + Green + Blue);
NormalizedBlue = Blue ./ (Red + Green + Blue);

courtImage(:, :, 1) = NormalizedRed;
courtImage(:, :, 2) = NormalizedGreen;
courtImage(:, :, 3) = NormalizedBlue;

courtImage = mat2gray(courtImage);

end

