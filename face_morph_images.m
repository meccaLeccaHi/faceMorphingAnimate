function IMAGE_MAT = face_morph_images(varargin)
% IMAGE_MAT = face_morph_images(FRAME_NUMBER)
% creates image matrix from face images (for visualization) 
% 
% last modified 03-09-17
% apj

% choose which frames to generate based on input
if any(length(varargin))
    FRAME_NUM                   = varargin{:};
else
    FRAME_NUM                   = 1;
end

% declare paths
MAIN_DIR                       = fullfile(filesep,'home',getUserName,...
                                    'Cloud2','movies','human');
FACE_DIR                       = fullfile(MAIN_DIR,'faces','fin_frames');

% set image properties
ALPHA_THRESH                   = 25; % alpha-channel threshold
IMG_BORDER                     = 30; % pixel-width

% declare number of steps on each trajectory
STEP_NUM                       = 4;
STEPS                          = 1/STEP_NUM:1/STEP_NUM:1;
        
% load order of faces from .csv files
FID                             = fopen(fullfile(MAIN_DIR,'turk',...
                            'results','proj2','reordered_nameList.csv'));
M                               = textscan(FID,'%s','Delimiter',',');
FACE_LIST                       = M{:};
fclose(FID);

% save to image matrix
IMAGE_MAT.LIST                  = FACE_LIST;
IMAGE_MAT.ORDER                 = [1 7 5 3];


%% read face average
TEMP_NAME                       = fullfile(FACE_DIR,'Ave',...
                            ['Average' '_' sprintf('%03d%',FRAME_NUM) 'RGB.tiff']);
PLOT_IMG                        = addborder(imread(TEMP_NAME),IMG_BORDER,[0 0 0],'inner'); % add black border
ALPHA                           = double(sum(PLOT_IMG,3) > ALPHA_THRESH); % a binary image to overlay

% save to image matrix
IMAGE_MAT.AVE                   = cat(3,PLOT_IMG,ALPHA); 

% preallocate remainder of image matrix for identity loop
IMAGE_MAT.RAD                   = cell(length(IMAGE_MAT.ORDER),length(STEPS));
IMAGE_MAT.TAN                   = cell(length(IMAGE_MAT.ORDER),length(STEPS)-1);

%% loop through identities
for I = 1:length(IMAGE_MAT.ORDER)
    
    % get current face name string
    IDENT_STR                   = IMAGE_MAT.LIST{IMAGE_MAT.ORDER(I)};
    
    % step through morph levels along each trajectory
    for II = 1:length(STEPS)
      
        %% read face morph image
        FILE_NAME               = [IDENT_STR sprintf('%03d%',STEPS(II)*100) ...
            'rad' '_' sprintf('%03d%',FRAME_NUM) 'RGB.tiff'];
        TEMP_NAME               = fullfile(FACE_DIR,IDENT_STR,'rad',...
            num2str(STEPS(II)*100),FILE_NAME);

        PLOT_IMG                = addborder(imread(TEMP_NAME),IMG_BORDER,[0 0 0],'inner'); % add black border
        ALPHA                   = double(sum(PLOT_IMG,3) > ALPHA_THRESH); % a binary image to overlay

        % save to image matrix
        IMAGE_MAT.RAD{I,II}     = cat(3,PLOT_IMG,ALPHA);
        
        % if at a morph step less than 100%, plot tangential morph
        if II<4

            % read face morph
            FILE_NAME           = [IDENT_STR sprintf('%03d%',STEPS(II)*100) ...
                'tan' '_' sprintf('%03d%',FRAME_NUM) 'RGB.tiff'];
            TEMP_NAME           = fullfile(FACE_DIR,IDENT_STR,'tan',...
                num2str(STEPS(II)*100),FILE_NAME);

            PLOT_IMG            = addborder(imread(TEMP_NAME),IMG_BORDER,[0 0 0],'inner'); % add black border
            ALPHA               = double(sum(PLOT_IMG,3) > ALPHA_THRESH); % a binary image to overlay

            % save to image matrix
            IMAGE_MAT.TAN{I,II} = cat(3,PLOT_IMG,ALPHA);
            
        end
    end
end
