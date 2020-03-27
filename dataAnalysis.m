
mainDir = "path to directory with directories containing csv files";
subDir1 = "/directory with csv files";
subDir2 = "/another directory with csv files";
fstart = 2; % file counter starts after initial file
global bigN % used for finding average and standard deviation
bigN = 0;
global sumTot % used for finding average and standard deviation
sumTot = 0;
global goodData % used for finding average and standard deviation
goodData = [0,0]; % this row will be removed before std calc
xbound1 = 1; % inches, used for specifying a region to get a standard dev in
xbound2 = 4; % inches, 

% finding my precious files
findFile = strcat(mainDir,subDir2); % concats strings
cd(findFile); % changes directory to your file
directoryFiles = dir; % gets a list of files in directory
fileNames = directoryFiles(3:length(directoryFiles)); 
% cuts off first 2 "files" that arent actually files but "." and ".."

% file stuff
firstFileName = fileNames(1).name; % grabs first file name as a character array
currentFile = string(firstFileName); % converts to string
% data cleaning
% Datapoints(dp) x 3 matrix from csv file (time,disp,force)
% [s,mm,kN] to be converted to [s,inches,lbf]
rawData = readmatrix(currentFile); 
cleanData = cleanMyData(rawData); % function that removes offsets and NAN rows
% collects data for statistics
getGoods(xbound1,xbound2,cleanData); % for standard deviation plots
plot(cleanData(:,1),cleanData(:,2)) % plots offset disp vs force
title('Force vs Displacement');
xlabel('Displacement (in)');
ylabel('Force (lbs)');
hold on

while fstart <= length(fileNames) % iterates through all files in folder
    fileName = fileNames(fstart).name; % same stuff as above
    currentFile = string(fileName);
    % data cleaning
    rawData = readmatrix(currentFile);
    cleanData = cleanMyData(rawData);
    % aggregates data for statistics
    getGoods(xbound1,xbound2,cleanData);
    plot(cleanData(:,1),cleanData(:,2))
    fstart = fstart + 1; % counts the counter
end
% average line plot
average = sumTot/bigN;
favg = ones(4,1)*average;
disp = (1:4);
plot(disp,favg)
% bound lines plot
yb = (0:0.1:1.8);
xb1 = ones(19,1)*xbound1;
xb2 = ones(19,1)*xbound2;
plot(xb1,yb)
plot(xb2,yb)
% standard deviation upper and lower plot
stData = goodData(2:end,:);
st = std(stData);
yuline = average + st(1,2);
yupp = ones(4,1)*yuline;
ybline = average - st(1,2);
ybot = ones(4,1)*ybline;
plot(disp,yupp,disp,ybot)
hold off

function data = cleanMyData(unrefined)
    rawData1 = unrefined(4:end,:); % cuts off NAN rows
    % 1st dp offset to shift all data to start at zero
    rawDatax1 = rawData1(:,2)-rawData1(1,2);
    rawDatax2 = rawDatax1./(25.4); % mm -> in
    rawDatay2 = rawData1(:,3).*(224.80894387096); % kN -> lbf
    data = [rawDatax2,rawDatay2];
end

function getGoods(start,stop,data) % range of data
    global goodData
    global bigN
    global sumTot
    % initializes counters
    xStart = 1;
    xStop = 1;
    % iterates through every single data point to get last index
    % of displacement value less than desired start and stop disps
    while data(xStart,1) <= start
        xStart = xStart + 1;
        xStop = xStart; % for increased speed than starting at 1
    end
    while data(xStop,1) <= stop
        xStop = xStop + 1;
    end
    % collected for standard deviation
    goodData = cat(1,goodData,data(xStart:xStop,:));
    % number of elements (might not be necessary)
    bigN = bigN + xStop - xStart;
    % sum of all force values (might not be necessary)
    sumTot = sumTot + sum(data(xStart:xStop,2));
end