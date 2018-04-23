function resultImage = AHE(numTiles,Image)
    sprintf('ԭͼ��ߴ磺%d,%d',size(Image))
    [numTiles,Image,dimTile] = PreProcessInput(numTiles,Image);
    tileMappings = makeTileMappings(numTiles,Image,dimTile);
    resultImage = makeAheImage(Image, tileMappings, numTiles,dimTile);
    sprintf('pad��ͼ��ߴ�:%d,%d',size(Image))
    sprintf('ÿ��tile�Ĵ�С;%d,%d',dimTile)
    

%==================================================================
function resultImage = makeAheImage(Image, tileMappings, numTiles,dimTile)
    % ����ԭͼ������
    resultImage = Image;
    resultImage(:) = 0;
    % ��ֵ����
    imgTileRow=1;
    for k=1:numTiles(1)+1
        if k == 1  %special case: top row
            imgTileNumRows = dimTile(1)/2; %always divisible by 2 because of padding
            mapTileRows = [1 1];
        else 
            if k == numTiles(1)+1 %special case: bottom row      
                imgTileNumRows = dimTile(1)/2;
                mapTileRows = [numTiles(1) numTiles(1)];
            else %default values
                imgTileNumRows = dimTile(1); 
                mapTileRows = [k-1, k]; %[upperRow lowerRow]
            end
        end
  
        % loop over columns of the tileMappings cell array
        imgTileCol=1;
        for l=1:numTiles(2)+1
            if l == 1 %special case: left column
                imgTileNumCols = dimTile(2)/2;
                mapTileCols = [1, 1];
            else
                if l == numTiles(2)+1 % special case: right column
                    imgTileNumCols = dimTile(2)/2;
                    mapTileCols = [numTiles(2), numTiles(2)];
                else %default values
                    imgTileNumCols = dimTile(2);
                    mapTileCols = [l-1, l]; % right left
                end
            end
            ulMapTile = tileMappings{mapTileRows(1), mapTileCols(1)};
            urMapTile = tileMappings{mapTileRows(1), mapTileCols(2)};
            blMapTile = tileMappings{mapTileRows(2), mapTileCols(1)};
            brMapTile = tileMappings{mapTileRows(2), mapTileCols(2)};
        
            normFactor = imgTileNumRows*imgTileNumCols; %normalization factor  
            subImage = Image(imgTileRow:imgTileRow+imgTileNumRows-1,imgTileCol:imgTileCol+imgTileNumCols-1);
            sImage = uint8(zeros(size(subImage)));
            %%====================================test
            if k==2 && l==2
                sprintf('ul:%d,%d| ur:%d,%d| bl:%d,%d| br:%d,%d',...
                    mapTileRows(1), mapTileCols(1),mapTileRows(1), mapTileCols(2),...
                    mapTileRows(2), mapTileCols(1),mapTileRows(2), mapTileCols(2))
                sprintf('tile size:%d,%d',imgTileNumRows,imgTileNumCols)
            end
            %%====================================test
            for i = 0:imgTileNumCols-1  %x
                inverseI = imgTileNumCols - i;  %1-x
                for j = 0:imgTileNumRows-1  %y
                    inverseJ = imgTileNumRows - j;  %1-y
                    val = subImage(j+1,i+1);
                    %=====================================test
                    if i==2 && j==2 && k==2 && l==2
                        sprintf('ԭ���ش�С��%d',val)
                        sprintf('��Ӧ�ĸ��ܱ�ת�������ش�С��%d,%d,%d,%d',ulMapTile(val+1),urMapTile(val+1),blMapTile(val+1),brMapTile(val+1))
                    end
                    %=====================================test
                    sImage(j+1, i+1) = (inverseJ*(inverseI*ulMapTile(val+1) + ...
                        i*urMapTile(val+1))+ j*(inverseI*blMapTile(val+1) +...
                        i*brMapTile(val+1)))/normFactor;
                    %=====================================test
                    if i==2 && j==2 && k==2 && l==2
                        sprintf('��ֵϵ����%d,%d')
                        sprintf('��ֵ���С��%d',sImage(j+1, i+1))
                    end
                    %=====================================test
                end
            end
            resultImage(imgTileRow:imgTileRow+imgTileNumRows-1,imgTileCol:imgTileCol+imgTileNumCols-1) = sImage;
            imgTileCol = imgTileCol + imgTileNumCols;
        end
        imgTileRow = imgTileRow + imgTileNumRows;
    end
        
        
        
            

%==================================================================
function tileMappings=makeTileMappings(numTiles,Image,dimTile)
   tileMappings = cell(numTiles);
   %extract and process each tile
   imgCol = 1;
   for col = 1:numTiles(2)
       imgRow = 1;
       for row = 1:numTiles(1)
           tile = Image(imgRow:imgRow+dimTile(1)-1,imgCol:imgCol+dimTile(2)-1);
           tileHist = get_hist(tile);
           tileMapping = pixel_map(tileHist,dimTile);
           tileMappings{row,col} = tileMapping;
           imgRow = imgRow + dimTile(1); 
       end
       imgCol = imgCol + dimTile(2);
   end
   sprintf('tileMappings��С��%d,%d',size(tileMappings))

%==================================================================
% �ж�ͼ���Ƿ���������ָ�粻�������ָ���߷ָ��ÿ��tile�ĳ����ż������pad
% numTiles: ���ָ�Ŀ���[m*n]
% Image: pad����֮���image
% dimTile: ÿ��tile�Ĵ�С
% noPadRect: û��padǰ��״̬����
function [numTiles,Image,dimTile]=PreProcessInput(numTiles,Image)
    dimI = size(Image);
    dimTile = dimI ./ numTiles;
    %check if tile size is reasonable
    if any(dimTile < 1)
        error(message('images:adapthisteq:inputImageTooSmallToSplit', num2str( numTiles )))
    end
    %check if the image needs to be padded; pad if necessary;
    %padding occurs if any dimension of a single tile is an odd number
    %and/or when image dimensions are not divisible by the selected 
    %number of tiles
    rowDiv  = mod(dimI(1),numTiles(1)) == 0;
    colDiv  = mod(dimI(2),numTiles(2)) == 0;
    if rowDiv && colDiv
        rowEven = mod(dimTile(1),2) == 0;
        colEven = mod(dimTile(2),2) == 0;  
    end
    if  ~(rowDiv && colDiv && rowEven && colEven)
        padRow = 0;
        padCol = 0;
        % ����л������޷�����Ҫ�ֵĿ�������ôpadding,ÿ��tile�ĳ�/������ֵȡ
        % dimI/numiles����ȡ����һ
        if ~rowDiv
            rowTileDim = floor(dimI(1)/numTiles(1)) + 1;
            padRow = rowTileDim*numTiles(1) - dimI(1);
        else
            rowTileDim = dimI(1)/numTiles(1);
        end
        
        
        if ~colDiv
            colTileDim = floor(dimI(2)/numTiles(2)) + 1;
            padCol = colTileDim*numTiles(2) - dimI(2);
        else
            colTileDim = dimI(2)/numTiles(2);
        end
        
        %check if tile dimensions are even numbers
        %�������ż������ôÿһ��tile��/������ֵ+1
        rowEven = mod(rowTileDim,2) == 0;
        colEven = mod(colTileDim,2) == 0;
        
        if ~rowEven
            padRow = padRow + numTiles(1);
        end
        if ~colEven
            padCol = padCol+numTiles(2);
        end
        padRowPre  = floor(padRow/2);
        padRowPost = ceil(padRow/2);
        padColPre  = floor(padCol/2);
        padColPost = ceil(padCol/2);
        
        %��ͼ����жԳ�pad����
        Image = padarray(Image,[padRowPre  padColPre ],'symmetric','pre');
        Image = padarray(Image,[padRowPost padColPost],'symmetric','post');
        
    end
    dimI = size(Image);
    dimTile = dimI ./ numTiles;
        
        
        
        