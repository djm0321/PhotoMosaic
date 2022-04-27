% PhotoData = readtable('naturePhotos.csv', 'Delimiter','comma');
PhotoData = table();
if exist('NaturePhotos', 'dir')
    PhotoData = readtable('naturePhotos.csv', 'Delimiter','comma');
else
    PhotoData = downloadImages();
end


I = imread("IMG_2609.jpg");
mosaic1 = makeMosaic(I, PhotoData);
imshow(mosaic1)



function finishedMosaic = makeMosaic(I, PhotoData)
[x, y, z] = size(I);
a = round(sqrt((x * y)/2500 ))
newX = floor(x/a)
newY = floor(y/a)
newX * newY;
imageList = [""];
for i =1:newY
    for j = 1:newX
        j + (i-1) * newX
        %imageList(end+1)
        [I, id] = getRandomPhoto(I, i, j, a, PhotoData);
        PhotoData((PhotoData.Var1 == id), :).USAGE = PhotoData((PhotoData.Var1 == id), :).USAGE + 1;

    end
end
%imageList = imageList(2:end);
%disp(imageList);
%fMontage = montage(imageList, 'Size', [newX newY]);
finishedMosaic = I(1:1:a*newX, 1:a*newY, :);
end
%montageImage = imread(fMontage.cData);
%imshow(montageImage)


function [mosaicPhoto, id] = getRandomPhoto(I, paneX, paneY, a, PhotoData)
    rect = [1 + a * (paneX - 1), 1 + a * (paneY - 1), a-1, a-1];
    focusIm = imcrop(I, rect);
    aR = mean(focusIm(:, :, 1), 'all');
    aG = mean(focusIm(:, :, 2), 'all');
    aB = mean(focusIm(:, :, 3), 'all');
%     for row = 1:size(PhotoData, 1)
%         if (PhotoData(row, :).USAGE) ~= -1
%             PhotoData(row, :).DIST = abs(PhotoData(row, :).R - aR) + abs(PhotoData(row, :).G - aG) + abs(PhotoData(row, :).B - aB);
%         else
%            PhotoData(row, :).DIST = realmax;
%         end
%     end
    for distance = 105:-10:5
        testTable = PhotoData(abs(PhotoData.R - aR) < distance & abs(PhotoData.G - aG) < distance & abs(PhotoData.B - aB) < distance, :);
        if size(testTable, 1) < 20
            testTable = PhotoData(abs(PhotoData.R - aR) < distance + 10 & abs(PhotoData.G - aG) < distance + 10 & abs(PhotoData.B - aB) < distance + 10, :);
            break
        end
    end
    size(testTable, 1);
    % x = ceil(rand * size(testTable, 1));
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
    %mosaicPhoto = temp{1};
    % newTable = sortrows(PhotoData, 'DIST', 'ascend');
    % testTable = newTable(1:10, :);
%     size(testTable);
%     minSSD = realmax;
%     rPic = "";
%     for i = 1:size(testTable, 1)
%         tName = testTable(i, :).SRC;
%         fImSize = size(focusIm);
%         t = imread(tName{1});
%         t = imresize(t, 50/a);
%         size(t);
%         rDiff = focusIm(:, :, 1) - t(:, :, 1);
%         gDiff = focusIm(:, :, 2) - t(:, :, 2);
%         bDiff = focusIm(:, :, 3) - t(:, :, 3);
%         rSSD = sum(rDiff(:).^2);
%         gSSD = sum(gDiff(:).^2);
%         bSSD = sum(bDiff(:).^2);
%         totalSSD = rSSD + gSSD + bSSD;
%         if minSSD > totalSSD
%             minSSD = totalSSD;
%             rPic = tName{1};
%         end
%     end
%     mosaicPhoto = rPic;
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
            PhotoData(i, :).USAGE = -1;
       end
    end
    toDelete = PhotoData.USAGE == -1;
    PhotoData(toDelete, :) = [];
    writetable(PhotoData, 'naturePhotos.csv');
    tileTable = PhotoData;
end