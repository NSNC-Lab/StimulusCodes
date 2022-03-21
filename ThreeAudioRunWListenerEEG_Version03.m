function ThreeAudioRunWListenerEEG_Version03(subj,numSec,ithSec,varargin)
% This version is for experiments during Nov/Dec.
% Add support for multiple breaks
% This is only for EEG
% numSec must evenly divide 360 trials

switch nargin
    case 0
        subj = 'test';
end
Screen('Preference', 'SkipSyncTests', 1);

%saveOp = 1;

% Check if Psychtoolbox is properly installed:
AssertOpenGL;
Screen('Preference', 'OverrideMultimediaEngine', 1); 
%s = serial('COM3');
%fopen(s);

devDir = 'C:\Users\mn0mn\Documents\Stimuli\Practice\Results';
devRootm = 'C:\Users\mn0mn\Documents\Stimuli\Practice\VideoFiles';
dirFaces = 'C:\Users\mn0mn\Documents\Stimuli\Practice\Faces';
transcriptDir = 'C:\Users\mn0mn\Documents\Stimuli\VideoClips\Transcripts';
dirAudio = 'C:\Users\mn0mn\Documents\Stimuli\Practice\AudioFiles';
 
[id,name] = GetKeyboardIndices;
  
cfg.kb = id;
% Wait until user releases keys on keyboard:
KbReleaseWait;

KbName('UnifyKeyNames');
cfg.space=KbName('SPACE');
cfg.esc=KbName('ESCAPE');
cfg.timeoutTime = 20;
cfg.key1 = '1';
cfg.key1m = '1!';
cfg.key2 = '2';
cfg.key2m = '2@';
cfg.key3 = '3';
cfg.key3m = '3#';
cfg.key4 = '4'; 
cfg.key4m = '4$';
cfg.key5 = '5';
cfg.key5m = '5%';
numAns = 5;

rectCoorList = zeros(4,numAns);

background=[0,0,0];

if nargin<4
    dnc = clock;
    dncstr = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3)) '_'];
else
    dncstr = varargin{1};
end

loadFileName = [devDir filesep 'iniList_' subj '_' dncstr '.mat'];
load(loadFileName,'indexMoviesTest', 'numTrials', 'uniqueMovies', 'maskerMovies', 'fixedMaskerList');

if ithSec > 1
%     load([devDir filesep 'response_3M_EEG_' subj '_' dncstr 'Temp'],'responsesA','correctRespA','responsesV','correctRespV');
    load([devDir filesep 'response_3A_EEG_' subj '_' dncstr 'Temp'],'responsesA','correctRespA');
else
%     responsesV = zeros(1,numTrials);
    responsesA = zeros(1,numTrials);
%     correctRespV = responsesV;
    correctRespA = zeros(1,numTrials);
end

if mod(numTrials,numSec) ~= 0
    error('Number of sections do not evenly divide the number of trials');
end

try
    InitializePsychSound(1);
    pahandle = PsychPortAudio('Open', [], [], 2, [], 2, 0);
    
    % Open 'windowrect' sized window on screen, with black [0] background color:
    [cfg.windowPtr1,rect1]=Screen('OpenWindow',1,background);
    [cfg.windowPtr2,rect2]=Screen('OpenWindow',2,background);
    [cfg.windowPtr3,rect3]=Screen('OpenWindow',3,background);
    
    [cfg.screenXpixels, cfg.screenYpixels] = Screen('WindowSize', cfg.windowPtr2);
    
    xOrder = [1, 2, 3, 4, 5];
    centerXCoors = xOrder*(cfg.screenXpixels/numAns)-(cfg.screenXpixels/numAns/2);
    centerYCoors = (cfg.screenYpixels/2)*ones(1,numAns);
    centerXCoorsTxt = ones(1,numAns)*(cfg.screenXpixels/2-800);
    centerYCoorsTxt = xOrder*((cfg.screenYpixels-250)/numAns);
    x1Coors = xOrder*(cfg.screenXpixels/numAns)-(cfg.screenXpixels/numAns/2)-100;
    x2Coors = xOrder*(cfg.screenXpixels/numAns)-(cfg.screenXpixels/numAns/2)+100;
    y1Coors = (cfg.screenYpixels/2)*ones(1,numAns)+100;
    y2Coors = (cfg.screenYpixels/2)*ones(1,numAns)-100;
    cfg.rectCoorList = zeros(4,numAns);
    
    startInd = (ithSec-1)*(numTrials/numSec)+1;
    endInd = (ithSec)*(numTrials/numSec);
    
    for i = startInd:endInd
        targetLocation = indexMoviesTest(i,2);
        textureList = zeros(1,5);
        theImageLocations = cell(1,5);
        textLocations = cell(1,5);
        switch targetLocation
            case 1
                currWinPtr = cfg.windowPtr2;
                textLocation = 3;
                targetAzimuth = '_-45';
                maskerAzimuth1 = '_45';
                maskerAzimuth2 = '_0';
                maskerWinPtr1 = cfg.windowPtr1;
                maskerWinPtr2 = cfg.windowPtr3;
            case 2
                currWinPtr = cfg.windowPtr1;
                textLocation = 1;
                targetAzimuth = '_45';
                maskerAzimuth1 = '_-45';
                maskerAzimuth2 = '_0';
                maskerWinPtr1 = cfg.windowPtr2;
                maskerWinPtr2 = cfg.windowPtr3;
            case 3
                currWinPtr = cfg.windowPtr3;
                textLocation = 5;
                targetAzimuth = '_0';
                maskerAzimuth1 = '_45';
                maskerAzimuth2 = '_-45';
                maskerWinPtr1 = cfg.windowPtr1;
                maskerWinPtr2 = cfg.windowPtr2;
        end
        
        centerWinPtr = cfg.windowPtr3;
        centerRect = rect3;
        
        randomMovies = datasample(maskerMovies,numAns,'Replace',false);
%         moviename1 = [devRootm filesep uniqueMovies{indexMoviesTest(i,1)} targetAzimuth '.mov'];
        moviename1 = [dirAudio filesep uniqueMovies{indexMoviesTest(i,1)} targetAzimuth '.wav'];
        if indexMoviesTest(i,3) == 0
            moviename2 = [dirAudio filesep randomMovies{2} maskerAzimuth1 '.wav'];
            moviename3 = [dirAudio filesep randomMovies{3} maskerAzimuth2 '.wav'];
        else
            moviename2 = [dirAudio filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} maskerAzimuth1 '.wav'];
            moviename3 = [dirAudio filesep fixedMaskerList{indexMoviesTest(i,1)*2} maskerAzimuth2 '.wav'];
        end
        
        for j = 1:numAns
%             if j == 1
%                 theImageLocations{j} = [dirFaces filesep uniqueMovies{indexMoviesTest(i,1)} '_Cropped.png'];
%             else
%                 theImageLocations{j} = [dirFaces filesep randomMovies{j} '_Cropped.png'];
%             end
            if j < 4
                if j == 1
                    textLocations{(j*2)-1} = [transcriptDir filesep uniqueMovies{indexMoviesTest(i,1)} '.txt'];
                else
                    textLocations{(j*2)-1} = [transcriptDir filesep randomMovies{j} '.txt'];
                end
                if j < 3
                    if j == 1
                        textLocations{j*2} = [transcriptDir filesep uniqueMovies{indexMoviesTest(i,1)} '_False.txt'];
                    else
                        textLocations{j*2} = [transcriptDir filesep randomMovies{j} '_False.txt'];
                    end
                end
            end
        end
        
%         if indexMoviesTest(i,3) == 1
%             theImageLocations{2} = [dirFaces filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '_Cropped.png'];
%             theImageLocations{3} = [dirFaces filesep fixedMaskerList{indexMoviesTest(i,1)*2} '_Cropped.png'];
%             textLocations{3} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '.txt'];
%             textLocations{4} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '_False.txt'];
%             textLocations{5} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2} '.txt'];
%         end
%         
%         imageLocationsShuffled = theImageLocations(randperm(numel(theImageLocations)));
%         findIndex = cellfun(@(x)isequal(x,theImageLocations{1}),imageLocationsShuffled);
%         correctRespV(i) = find(findIndex);
        
        textLocationsShuffled = textLocations(randperm(numel(textLocations)));
        findIndex = cellfun(@(x)isequal(x,textLocations{1}),textLocationsShuffled);
        correctRespA(i) = find(findIndex);
        
        Screen('TextSize', currWinPtr, 90);
        DrawFormattedText(currWinPtr, '+', 'center','center',[255,255,255]);
        Screen('Flip', currWinPtr);
%         fprintf(s,200);
        WaitSecs(2);
        
        Screen('FillRect', cfg.windowPtr1,background,rect1);
        Screen('FillRect', cfg.windowPtr2,background,rect2);
        Screen('FillRect', cfg.windowPtr3,background,rect3);
        Screen('Flip',cfg.windowPtr1);
        Screen('Flip',cfg.windowPtr2); 
        Screen('Flip',cfg.windowPtr3);
        
%         % Open movie file:
%         movie1 = Screen('OpenMovie', currWinPtr, moviename1);
%         movie2 = Screen('OpenMovie', maskerWinPtr1, moviename2);
%         movie3 = Screen('OpenMovie', maskerWinPtr2, moviename3);

        audioFileName1 = moviename1;
        audioFileName2 = moviename2;
        audioFileName3 = moviename3;
        disp(audioFileName1);
        disp(audioFileName2);
        disp(audioFileName3);
        [wavedata1, freq1] = audioread(audioFileName1);
        [wavedata2, freq2] = audioread(audioFileName2);
        [wavedata3, freq3] = audioread(audioFileName3);
        
        try
            wavedata = (wavedata1./3 + wavedata2./3 + wavedata3./3);
        catch e
            sca;
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            fprintf(1,'Line%d',e.stack.line);
        end

        PsychPortAudio('FillBuffer', pahandle, wavedata');
        
        PsychPortAudio('Start', pahandle, [],0);
        
        Priority(2);
%         fprintf(s,210);
%         % Start playback engine:
%         Screen('PlayMovie', movie1, 1);
%         Screen('PlayMovie', movie2, 1);
%         Screen('PlayMovie', movie3, 1);
        %fprintf(s,255);
        
        % Playback loop: Runs until end of movie or keypress:
%         while ~KbCheck
%             % Wait for next movie frame, retrieve texture handle to it
%             tex1 = Screen('GetMovieImage', currWinPtr, movie1);
%             tex2 = Screen('GetMovieImage', maskerWinPtr1, movie2);
%             tex3 = Screen('GetMovieImage', maskerWinPtr2, movie3);
% 
%             % Valid texture returned? A negative value means end of movie reached:
%             if tex1<=0
%                 % We're done, break out of loop:
%                 break;
%             end 
% 
%             % Draw the new texture immediately to screen:
%             Screen('DrawTexture', currWinPtr, tex1);
%             Screen('DrawTexture', maskerWinPtr1, tex2);
%             Screen('DrawTexture', maskerWinPtr2, tex3);
%  
%             % Update display:
%             Screen('Flip', currWinPtr);
%             Screen('Flip', maskerWinPtr1);
%             Screen('Flip', maskerWinPtr2);
% 
%             % Release texture: 213
%             Screen('Close', tex1);
%             Screen('Close', tex2);
%             Screen('Close', tex3);
%         end
%         fprintf(s,230);
        
        PsychPortAudio('Stop', pahandle,1,1);% Wait until sound playback stops
        PsychPortAudio('DeleteBuffer');
        
%         for j = 1:numAns
%             theImage = imread(imageLocationsShuffled{j});
%             rectCoorList(:,j) = [x2Coors(j), y2Coors(j),x1Coors(j), y1Coors(j)];
%             textureList(j) =  Screen('MakeTexture', centerWinPtr, theImage);
%         end 
%         
%         Screen('DrawTextures', centerWinPtr, textureList, [], rectCoorList);
%     
%         for k = 1:5
%             Screen('DrawText',centerWinPtr,num2str(k),centerXCoors(k)-100,centerYCoors(k)-200,[255 255 255]);
%         end
%         Screen('Flip',centerWinPtr);
        
%         fprintf(s,220);
%         % Stop playback:
%         Screen('PlayMovie', movie1, 0);
%         Screen('PlayMovie', movie2, 0);
%         Screen('PlayMovie', movie3, 0);
%         % Close movie:
%         Screen('CloseMovie', movie1);
%         Screen('CloseMovie', movie2);
%         Screen('CloseMovie', movie3);
        
%         cfg.stimEndTime = GetSecs;
%         responsesV(i) = getResponse(cfg);
        
%         Screen('Close',textureList);
        ansList = cell(numAns,1);
        
        for j = 1:numAns
            fileName = textLocationsShuffled{j};
            fileID = fopen(fileName,'r'); 
            ansList{j} = fscanf(fileID,'%c'); 
        end
        
        Screen('TextSize', centerWinPtr, 40);
        for k = 1:5
            Screen('DrawText',centerWinPtr,[num2str(k) '.   ' ansList{k}],centerXCoorsTxt(k),centerYCoorsTxt(k),[255 255 255]);
        end
        Screen('Flip',centerWinPtr);
        
        cfg.stimEndTime = GetSecs;
        responsesA(i) = getResponse(cfg);
        fclose('all');
        
        if i < endInd
            Screen('TextSize', centerWinPtr, 90);
            DrawFormattedText(centerWinPtr, 'PRESS SPACE', 'center','center',[255,255,255]);
            Screen('Flip', centerWinPtr);
        elseif ithSec ~= numSec
            Screen('TextSize', centerWinPtr, 90);
            DrawFormattedText(centerWinPtr, 'TAKE A BREAK', 'center','center',[255,255,255]);
            Screen('Flip', centerWinPtr);
        else
            Screen('TextSize', centerWinPtr, 90);
            DrawFormattedText(centerWinPtr, 'FINISHED', 'center','center',[255,255,255]);
            Screen('Flip', centerWinPtr);
        end
        
        while(1)
            [keyIsDown,secs ,keyCode]=KbCheck; %#ok<ASGLU>
            if (keyIsDown==1 && keyCode(cfg.space))
%                 fprintf(s,240);
                % Set the abort-demo flag.
                Screen('FillRect', centerWinPtr,background,centerRect);
                Screen('Flip',centerWinPtr);
                break;
            end
            if (keyIsDown==1 && keyCode(cfg.esc))
                % Set the abort-demo flag.
                sca;
                break;
            end
        end
        Priority(2);
    end
    
    % Close Screen, we're done: 
    PsychPortAudio('Close', pahandle);
    sca;
    dnc = clock;
    dncstr = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3)) '_' num2str(dnc(4)) num2str(dnc(5))];
    dncstr2 = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3))];

%     if saveOp == 1
%         save([devDir filesep 'response_3M_EEG_' subj '_' dncstr],'responsesA','correctRespA','responsesV','correctRespV');
%     end
    
    if ithSec < numSec
        save([devDir filesep 'response_3A_EEG_' subj '_' dncstr2 '_Temp'],'responsesA','correctRespA');
    else
        save([devDir filesep 'response_3A_EEG_' subj '_' dncstr],'responsesA','correctRespA');
    end
    
catch e
    sca;
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    fprintf(1,'Line%d',e.stack.line);
end

return 

end

function response = getResponse(cfg)

% This subfunction uses  to wait for participants to press a key; it
% checks whether it's a legal key and records the key and the time it was
% pressed.

response = 0;

KbQueueCreate(cfg.kb);
KbQueueStart(cfg.kb);

% As long as it's before the timeout
while (GetSecs - cfg.stimEndTime < cfg.timeoutTime)
    % Look for keypresses
    [pressed, firstPress]=KbQueueCheck(cfg.kb);
    % If a key is pressed
    if numel(find(firstPress)) == 1
        k = find(firstPress); % Key1code of pressed key
        if pressed && ismember(k, [KbName(cfg.key1) KbName(cfg.key1m) KbName(cfg.key2) KbName(cfg.key2m) KbName(cfg.key3) KbName(cfg.key3m) KbName(cfg.key4) KbName(cfg.key4m) KbName(cfg.key5) KbName(cfg.key5m)])
            try
                switch k
                    case {KbName(cfg.key1), KbName(cfg.key1m)}
                        r = 1;
                    case {KbName(cfg.key2), KbName(cfg.key2m)}
                        r = 2;
                    case {KbName(cfg.key3), KbName(cfg.key3m)}
                        r = 3;
                    case {KbName(cfg.key4), KbName(cfg.key4m)}
                        r = 4;
                    case {KbName(cfg.key5), KbName(cfg.key5m)}
                        r = 5;
                end
                response = r;
                break;
            catch
                disp('failure');
                break;
            end
        end
    else
        % Multiple keys pressed
        response = -999;
    end
end
% disp(pressed);
% disp(firstPress);
KbQueueRelease(cfg.kb);
% 
% Timeout.
if GetSecs - cfg.stimEndTime > cfg.timeoutTime
    response = -999;
end

end