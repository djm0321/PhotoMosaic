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
    m = makeMosaic(I, PhotoData);
    figure; imshow(m);
end


function finishedMosaic = makeMosaic(I, PhotoData)
[y, x, z] = size(I);
a = round(sqrt((y * x)/2500 ))
newY = floor(y/a)
newX = floor(x/a)
newY * newX;
imageList = [""];
for i =1:newX
    for j = 1:newY
        j + (i-1) * newY
        [I, id] = getRandomPhoto(I, i, j, a, PhotoData);
        PhotoData((PhotoData.Var1 == id), :).USAGE = PhotoData((PhotoData.Var1 == id), :).USAGE + 1;

    end
end
finishedMosaic = I(1:1:a*newY, 1:a*newX, :);
end


function [mosaicPhoto, id] = getRandomPhoto(I, paneX, paneY, a, PhotoData)
    rect = [1 + a * (paneX - 1), 1 + a * (paneY - 1), a-1, a-1];
    focusIm = imcrop(I, rect);
    aR = mean(focusIm(:, :, 1), 'all');
    aG = mean(focusIm(:, :, 2), 'all');
    aB = mean(focusIm(:, :, 3), 'all');
    for distance = 105:-10:5
        testTable = PhotoData(abs(PhotoData.R - aR) < distance & abs(PhotoData.G - aG) < distance & abs(PhotoData.B - aB) < distance, :);
        if size(testTable, 1) < 20
            testTable = PhotoData(abs(PhotoData.R - aR) < distance + 10 & abs(PhotoData.G - aG) < distance + 10 & abs(PhotoData.B - aB) < distance + 10, :);
            break
        end
    end
    size(testTable, 1);
    testTable = sortrows(testTable, 'USAGE', 'ascend');
    temp = testTable(1, :).SRC;
    asd = testTable(1, :).Var1;
    usage = PhotoData(PhotoData.Var1 == asd, :).USAGE;
    sizeOfTable = size(testTable, 1);
    tester = imread(temp{1});
    tester = imresize(tester, a/50);
    size(tester);
    I(1 + a * (paneY - 1): 1 + a * (paneY - 1) + (a - 1), 1 + a * (paneX - 1): 1 + a * (paneX - 1) + (a - 1), :) = I(1 + a * (paneY - 1): 1 + a * (paneY - 1) + (a - 1), 1 + a * (paneX - 1): 1 + a * (paneX - 1) + (a - 1), :) .* .3 + tester .* .7;
    mosaicPhoto = I;
    id = testTable(1, :).Var1;
end

function tileTable = downloadImages()
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
    mkdir NaturePhotos
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
    toDelete = PhotoData.USAGE == -1;
    PhotoData(toDelete, :) = [];
    writetable(PhotoData, 'naturePhotos.csv');
    tileTable = PhotoData;
end

function newData = GitHubURL(PhotoData)
    for i = 1:size(PhotoData, 1)
        
    end
end