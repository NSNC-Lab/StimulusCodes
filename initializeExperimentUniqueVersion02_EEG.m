% Updated to use unique video clips for each speaker.
% Mix single target and target+maskers conditions
% video clips for single target are different from clips in target+maskers
% ADD Pure tone to white cross!!!
% parameters for EEG
% change from 360 trials to 300 trials

function initializeExperimentUniqueVersion02_EEG(subj)
    % Apply to both EEG and fNIRS
    
% Need to add clip # and Trim. 20 movies
    movieList = {'3gcWAZSNi2E_M','4dUJVqvs2Qo_M','5TLu2RXT6Gs_M','9b0OSsywmw8_M','AQDWwktBhaw_F',...
        'bNoDFfCAMoE_F','cAL19Dz11rI_M','D637a3S8rII_F','f_Id9iuwYCI_M','gTbBA55oVtA_F',...
        'JpJoybtabbU_F','lD7C0LfbOhk_F','lxm6ez2cx6Y_F','nFGK6F9cYgk_M','OK4yFNuh-cM_F',...
        'oUtIW6KbWA4_M',...%'QoQF8N5ZsQA_F',...
        'RdUVaYI3bmg_M','sZdAE3kcfT8_M','WfpZPDqNNg0_M','W-OhDc_uT6o_M'};
    
    % 50 movies
    maskerList = {'d3PRIpHimC8_F_Trim',...
        '0jn812_5_0I_F_Trim',...
        '2JQlmOAiFec_F_Trim','2pozcQMn5TQ_F_Trim','2Z7hykZbeZo_F_Trim','9dMsDgWMq1w_F_Trim','9jLuF29IZJ4_M_Trim',...
        '92EPWy3Q3xY_F_Trim','432K4HMqXqM_F_Trim','aL00a3sfnYM_F_Trim','biAbh6hSl-8_F_Trim','BR8_vutYlKw_M_Trim',...
        'COPwkhDKuTY_F_Trim','dD0dzpD1zOA_F_Trim','eSCWILFxIcI_M_Trim',...
        'FHVOieJ3KkM_M_Trim','gS-3u7nX4rs_M_Trim','Hgk3oKuflW4_M_Trim','HLUoTtwbV9g_F_Trim','i2g3DtSNswg_M_Trim',...
        'j_pxbAu73Cs_M_Trim','jmkpZc1hqOI_F_Trim','k2o-SEI3PF4_F_Trim','KT_xYgjM7L8_M_Trim',...
        'lmT1r_vUCMY_M_Trim','mqWvPPN_ZF4_M_Trim','mXVR5cPjjng_F_Trim','OTUhCqcime4_F_Trim','P40YEi9w1cA_M_Trim',...
        'pbBJrYeC4e4_M_Trim','pxtRlKs0pAg_M_Trim','QDh_JkAR6_o_F_Trim','rgh1AmNKqvM_F_Trim','RnCFghHdXPs_F_Trim',...
        's2uYEQ73eE4_M_Trim','uYk_bOoAIhc_M_Trim','Wstpqq4iCNI_M_Trim',...
        'YMtfgkS15_w_M_Trim','zTf1cjDUtLw_F_Trim','97-JvV8WIBQ_M_Trim','ceWFr4z_KZo_M_Trim','Ed2BIOHbQ_F_Trim','IrXrbrZWflA_M_Trim',...
        'RSZLM4P37xk_M_Trim','SJwPr78ZYbI_F_Trim','UC2G7jUr4J0_F_Trim',...
        'uipEQlOMu6U_F_Trim','Wk_xCUY7els_M_Trim','Y5KXyN4UoJY_F_Trim','YMOmSUiUvlk_F_Trim'}; 

    devDir = 'C:\Users\mn0mn\Documents\Stimuli\Practice\Results';
    
    % Default = 12
    % number of unique movies for each experiment. Total is 2*uniMovies
    uniMovies = 10;
    %uniMovies = 3;
    uniClips = 5;
    uniClipID1 = 1:1:floor(uniClips/2);
    uniClipID2 = ceil(uniClips/2):1:uniClips;
%     uniClipID1 = 1:1:uniClips/2;
%     uniClipID2 = uniClips/2+1:1:uniClips;
    % Default = 10
    % MUST BE EVEN
    movieLocRep = 5;
    %movieLocRep = 2;
    
    uniqueMovies = datasample(movieList,uniMovies*2,'Replace',false);
    maskerMovies = maskerList;
%    fixedMaskers = cell(1,uniMovies*2);
%     for i = 1:uniMovies
%         maskerMovies(ismember(maskerMovies,uniqueMovies{i})) = [];
%     end
    fixedMaskerList = datasample(maskerList,uniMovies*4,'Replace',false);
    for i = 1:uniMovies*4
        maskerMovies(ismember(maskerMovies,fixedMaskerList{i})) = [];
    end
    indexMoviesSorted = 1:uniMovies;
    indexMoviesSorted = indexMoviesSorted';
    indexMoviesSorted2 = [uniMovies+1:1:2*uniMovies]';
    tempCol1 = [];
    tempCol2 = [];
    tempCol3 = [];
    indexMoviesRandom1 = [];
    indexMoviesRandom2 = [];
    indexMoviesRandom3 = [];
    clipIDCol1 = [];
    clipIDCol2 = [];
    clipIDCol3 = [];
    
    % spatial location
    for i = 1:3
        % movie repitition
        for j = 1:floor(movieLocRep/2)
            indexMoviesRandom1 = [indexMoviesRandom1; indexMoviesSorted(randperm(size(indexMoviesSorted,1)))];
        end
        tempCol1 = [tempCol1; i*ones(size(indexMoviesSorted,1)*floor(movieLocRep/2),1)];
        clipIDCol1 = [clipIDCol1; repmat(uniClipID1',size(indexMoviesSorted,1),1)];
    end
    tempCol31 = zeros(size(indexMoviesRandom1));
    tempWhichExp1 = zeros(size(indexMoviesRandom1));
    
    for i = 1:3
        for j = 1:ceil(movieLocRep/2)
            indexMoviesRandom2 = [indexMoviesRandom2; indexMoviesSorted(randperm(size(indexMoviesSorted,1)))];
        end
        tempCol2 = [tempCol2; i*ones(size(indexMoviesSorted,1)*ceil(movieLocRep/2),1)];
        clipIDCol2 = [clipIDCol2; repmat(uniClipID2',size(indexMoviesSorted,1),1)];
    end
    tempCol32 = ones(size(indexMoviesRandom2));
    tempWhichExp2 = zeros(size(indexMoviesRandom2));
    
    for i = 1:3
        for j = 1:movieLocRep
            indexMoviesRandom3 = [indexMoviesRandom3; indexMoviesSorted2(randperm(size(indexMoviesSorted2,1)))];
        end
        tempCol3 = [tempCol3; i*ones(size(indexMoviesSorted2,1)*movieLocRep,1)];
        clipIDCol3 = [clipIDCol3; repmat([1:movieLocRep]',size(indexMoviesSorted2,1),1)];
    end
    tempCol33 = ones(size(indexMoviesRandom3));
    tempWhichExp3 = ones(size(indexMoviesRandom3));
    
    indPart1 = [indexMoviesRandom1 tempCol1 tempCol31 clipIDCol1 tempWhichExp1];
    indPart2 = [indexMoviesRandom2 tempCol2 tempCol32 clipIDCol2 tempWhichExp2];
    indPart3 = [indexMoviesRandom3 tempCol3 tempCol33 clipIDCol3 tempWhichExp3];
    indexMoviesRandom = [indPart1; indPart2; indPart3];
    randInd = randperm(size(indexMoviesRandom,1));
    % first col is movie ID, second col is location, third col is boolean
    % (unique maskers), fourth col is clip #, fifth col is experiment # (1 or 2)
    indexMoviesTest = [indexMoviesRandom(randInd,1) indexMoviesRandom(randInd,2) indexMoviesRandom(randInd,3) indexMoviesRandom(randInd,4) indexMoviesRandom(randInd,5)];
    numTrials = size(indexMoviesTest,1);
    
    dnc = clock;
    dncstr = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3)) '_'];
    
    fileName = [devDir filesep 'iniList_' subj '_' dncstr '.mat'];
    save(fileName, 'indexMoviesTest', 'numTrials', 'uniqueMovies', 'maskerMovies', 'fixedMaskerList');
end
    