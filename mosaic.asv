% Create Empty Data table for image info. If images not downloaded,
% download them. If they have been downloaded, open up .csv containing
% image information.
PhotoData = table();
if exist('NaturePhotos', 'dir')
    PhotoData = readtable('naturePhotos.csv', 'Delimiter','comma');
else
    PhotoData = downloadImages();
end

% Iterate through all images in ./srcImages and make mosaic for each
sourceImages = dir("srcImages");
sourceImages = sourceImages(3:end, :);
for i = 1:size(sourceImages, 1)
    imSrc = ['./srcImages/' sourceImages(i, :).name]
    I = imread(imSrc);
    m = makeMosaic(I, PhotoData, 2500);
    figure; imshow(m);
end

% Creates mosaic
function finishedMosaic = makeMosaic(I, PhotoData, numTiles)
% Finds size and figures out size of image necessary to fit roughly
% numTiles tiles in the mosaic
[y, x, z] = size(I);
a = round(sqrt((y * x)/numTiles))
newY = floor(y/a)
newX = floor(x/a)
newY * newX;
I = I(1:1:a*newY, 1:a*newX, :);
% Iterates through each segment, adding tile to overall image with
% each call to getRandomPhoto
for i =1:newX
    for j = 1:newY
        j + (i-1) * newY
        [I, id] = getRandomPhoto(I, i, j, a, PhotoData);
        PhotoData((PhotoData.Var1 == id), :).USAGE = PhotoData((PhotoData.Var1 == id), :).USAGE + 1;
    end
end
% returns finished mosaic
finishedMosaic = I;
end


function [mosaicPhoto, id] = getRandomPhoto(I, paneX, paneY, a, PhotoData)
    % Crops image to focus on only current tile, and gets mean pixel
    % values for the tile for R, G, and B
    rect = [1 + a * (paneX - 1), 1 + a * (paneY - 1), a-1, a-1];
    focusIm = imcrop(I, rect);
    aR = mean(focusIm(:, :, 1), 'all');
    aG = mean(focusIm(:, :, 2), 'all');
    aB = mean(focusIm(:, :, 3), 'all');
    % Finds closest pixel distance where there are a sufficient number
    % of photos to draw from so that the same image isn't overused.
    % When less than 20 images available, return to higher cutoff.
    for distance = 105:-10:5
        closeTable = PhotoData(abs(PhotoData.R - aR) < distance & abs(PhotoData.G - aG) < distance & abs(PhotoData.B - aB) < distance, :);
        if size(closeTable, 1) < 20
            closeTable = PhotoData(abs(PhotoData.R - aR) < distance + 10 & abs(PhotoData.G - aG) < distance + 10 & abs(PhotoData.B - aB) < distance + 10, :);
            break
        end
    end
    % Sorts table by usage, then picks lowest usage value (so that images
    % are reused as little as possible)
    size(closeTable, 1);
    closeTable = sortrows(closeTable, 'USAGE', 'ascend');
    tileSrc = closeTable(1, :).SRC;
    % Opens tile, sizes it correctly, adds it to image, and returns
    % Updated image.
    tile = imread(tileSrc{1});
    tile = imresize(tile, a/50);
    I(1 + a * (paneY - 1): 1 + a * (paneY - 1) + (a - 1), 1 + a * (paneX - 1): 1 + a * (paneX - 1) + (a - 1), :) = I(1 + a * (paneY - 1): 1 + a * (paneY - 1) + (a - 1), 1 + a * (paneX - 1): 1 + a * (paneX - 1) + (a - 1), :) .* .3 + tile .* .7;
    imshow(I)
    mosaicPhoto = I;
    id = closeTable(1, :).Var1;
end

%If images are undownloaded, download images
function tileTable = downloadImages()
    % Create fully fledged PhotoData table
    PhotoData = readtable('nature.csv', 'Delimiter','comma');
    PhotoData.Properties.VariableNames{2} = 'URL';
    PhotoData.Properties.VariableNames{3} = 'SRC';
    PhotoData.R(1,1) = 0;
    PhotoData.G(1,1) = 0;
    PhotoData.B(1,1) = 0;
    PhotoData.USAGE(1, 1) = 0;
    PhotoData.Var8(1,1) = 0;
    PhotoData.Properties.VariableNames{8} = 'DIST';
    targetSize = [50, 50];
    % Make directory to store images in (for cleanliness)
    mkdir NaturePhotos
    % Download each image from stored URL and save it as a 50x50 image
    for i = 1:size(PhotoData, 1)
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
        % If photo is in color and large enough, crop image and store
        % average RGB value
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
            PhotoData(i, :).USAGE = -1;
       end
    end
    % Remove bad photos from database
    toDelete = PhotoData.USAGE == -1;
    PhotoData(toDelete, :) = [];
    writetable(PhotoData, 'naturePhotos.csv');
    tileTable = PhotoData;
end