%% set the directory name
dirname = '60mrnaCropped';

%% show a phase and a fluorescence image
imageFolder = [dirname,filesep,'raw_im',filesep];

% finds all phase and fluorescence images
phaseIm = dir([imageFolder,'*c1.tif']);
fluorIm = dir([imageFolder,'*c2.tif']);

% reads the first one
phase = imread([imageFolder,phaseIm(1).name]);
fluor = imread([imageFolder,fluorIm(1).name]);

figure(1);
clf;
imshow(phase);

figure(2);
clf;
imshow(fluor,[])

%% try different constants to select the most appropriate one
tryDifferentConstants([dirname,'/raw_im/']);


%% Load the constants and set the desired values
CONST = loadConstantsNN ('60XEclb',0);

% fit up to 5 foci in each cell
CONST.trackLoci.numSpots = [5]; % Max number of foci to fit in each fluorescence channel (default = [0 0])

% find the neighbors
CONST.trackOpti.NEIGHBOR_FLAG = true;

% not verbose state
CONST.parallel.verbose = 0;

%% Segment the data 
% setting clean flag to true to resgment data
clean_flag = 1;
close all; % close all figures
BatchSuperSeggerOpti (dirname,1,clean_flag,CONST);

%% Load an individual cell file
cell_dir = [dirname,filesep,'xy1',filesep,'cell',filesep];
cellData = dir([cell_dir,'Cell*.mat']);
data = load([cell_dir,cellData(2).name]);

%% Show the cell mask for frame 1
timeFrame = 1;
mask = data.CellA{timeFrame}.mask;
figure;
clf;
imshow(mask)

%% Show the phase image for frame 1
figure;
clf;
imshow(data.CellA{timeFrame}.phase,[])

%% Show the fluorescence image for frame 1
figure;
clf;
imshow(cat(3,mask*0,ag(data.CellA{timeFrame}.fluor1),mask*0),[])

%% Make a cell tower 
figure;
clf;
im_tmp = makeFrameMosaic(data, CONST,2,1,3);

%% Make a kymograph
figure;
clf;
makeKymographC(data,1,CONST,1)

