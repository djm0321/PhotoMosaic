PhotoData = readtable('naturalPhotos.csv', 'Delimiter','comma');
PhotoData.Var8(1,1) = 0;
PhotoData.Properties.VariableNames{8} = 'DIST';

I = imread("IMG_2609.jpg");
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
I = I(1:1:a*newX, 1:a*newY, :);
imshow(I)
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