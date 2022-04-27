



% PhotoData = readtable('urls.csv', 'Delimiter','comma');
PhotoData = readtable('nature.csv', 'Delimiter','comma');
PhotoData.Properties.VariableNames{2} = 'URL';
PhotoData.Properties.VariableNames{3} = 'SRC';
PhotoData.R(1,1) = 0;
PhotoData.G(1,1) = 0;
PhotoData.B(1,1) = 0;
PhotoData.USAGE(1, 1) = 0;
targetSize = [50, 50]
for i = 1:size(PhotoData, 1)
    % imgName = strcat('./MosaicStuff/',num2str(PhotoData.Var1(i)), '.jpg')
    imgName = strcat('./NaturePhotos/',num2str(PhotoData.Var1(i)), '.jpg')
    temp = PhotoData.URL(i);
    PhotoData.SRC(i) = {imgName};
    loaded = 0;
    try
        I = imread(temp{1});
        loaded = 1;
    catch
        disp('file not found');
    end
    size(size(I), 2);
    if (size(size(I), 2) == 3 & loaded == 1 & size(I, 1) >= 50 & size(I, 2) >= 50)
        cropWindow = centerCropWindow2d(size(I), targetSize);
        finalImage = imcrop(I, cropWindow);
        size(I);
        PhotoData.R(i) = mean(finalImage(:, :, 1), 'all');
        PhotoData.B(i) = mean(finalImage(:, :, 2), 'all');
        PhotoData.G(i) = mean(finalImage(:, :, 3), 'all');
        imwrite(finalImage, imgName);
    else
        disp('bad photo')
        PhotoData.USAGE(i) = -1;
   end
end
toDelete = PhotoData.USAGE == -1;
PhotoData(toDelete, :) = [];
writetable(PhotoData, 'naturePhotos.csv');
