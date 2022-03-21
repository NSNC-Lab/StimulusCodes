function MixedRunWListenerEEG_Version01(subj,numSec,ithSec)
% This version is for experiments during Nov/Dec.
% Add support for multiple breaks
% This is only for EEG

diary 'EEGlog.txt'
tic;

opTrigger = 1;

% if opTrigger == 1
%     %s = serial('COM1');
%     s = serialport("COM3",9600);
%     fopen(s);
% end

switch nargin
    case 0
        subj = 'test';
end
Screen('Preference', 'SkipSyncTests', 1);

%saveOp = 1;

% Check if Psychtoolbox is properly installed:
AssertOpenGL;
Screen('Preference', 'OverrideMultimediaEngine', 1); 
% s = serial('COM3');
% fopen(s);

devDir = 'C:\Users\mn0mn\Documents\Stimuli\Practice\Results';
devRootm = 'C:\Users\mn0mn\Documents\Stimuli\Practice\VideoFiles';
devClips = 'C:\Users\mn0mn\Documents\Stimuli\VideoClipsUpdated';
dirFaces = 'C:\Users\mn0mn\Documents\Stimuli\Practice\Faces';
transcriptDir = 'C:\Users\mn0mn\Documents\Stimuli\VideoClips\Transcripts';
transcriptDirUpdated = 'C:\Users\mn0mn\Documents\Stimuli\VideoClipsUpdated\Transcripts';
 
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

if opTrigger == 1
    cfg.com = BioSemiSerialPort();
end

numAns = 5;

rectCoorList = zeros(4,numAns);

background=[0,0,0];
dnc = clock;
dncstr = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3)) '_'];

loadFileName = [devDir filesep 'iniList_' subj '_' dncstr '.mat'];
load(loadFileName,'indexMoviesTest', 'numTrials', 'uniqueMovies', 'maskerMovies', 'fixedMaskerList');

if ithSec > 1
    load([devDir filesep 'response_3M_EEG_' subj '_' dncstr 'Temp'],'responsesA','correctRespA','responsesV','correctRespV');
else
    responsesV = zeros(1,numTrials);
    responsesA = zeros(1,numTrials);
    correctRespV = responsesV;
    correctRespA = responsesV;
end

if mod(numTrials,numSec) ~= 0
    error('Number of sections do not evenly divide the number of trials');
end

cfg.Trigger1 = zeros(1,numTrials);
cfg.Trigger2 = zeros(1,numTrials);
cfg.Trigger3 = zeros(1,numTrials);
cfg.Trigger4 = zeros(1,numTrials);


try
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
        trialStopped = i;
        targetLocation = indexMoviesTest(i,2);
        textureList = zeros(1,5);
        theImageLocations = cell(1,5);
        textLocations = cell(1,5);
        switch targetLocation
            case 1
                % right
                currWinPtr = cfg.windowPtr1;
                textLocation = 1;
                targetAzimuth = '_-45';
                maskerAzimuth1 = '_45';
                maskerAzimuth2 = '_0';
                maskerWinPtr1 = cfg.windowPtr2;
                maskerWinPtr2 = cfg.windowPtr3;
                audioCue = 'C:\Users\mn0mn\Documents\Stimuli\Practice\cue-45.mov';
            case 2
                % left
                currWinPtr = cfg.windowPtr2;
                textLocation = 3;
                targetAzimuth = '_45';
                maskerAzimuth1 = '_-45';
                maskerAzimuth2 = '_0';
                maskerWinPtr1 = cfg.windowPtr1;
                maskerWinPtr2 = cfg.windowPtr3;
                audioCue = 'C:\Users\mn0mn\Documents\Stimuli\Practice\cue45.mov';
            case 3
                % center
                currWinPtr = cfg.windowPtr3;
                textLocation = 5;
                targetAzimuth = '_0';
                maskerAzimuth1 = '_45';
                maskerAzimuth2 = '_-45';
                maskerWinPtr1 = cfg.windowPtr1;
                maskerWinPtr2 = cfg.windowPtr2;
                audioCue = 'C:\Users\mn0mn\Documents\Stimuli\Practice\cue0.mov';
        end
        
        centerWinPtr = cfg.windowPtr3;
        centerRect = rect3;
        
        randomMovies = datasample(maskerMovies,numAns,'Replace',false);
        moviename1 = [devClips filesep uniqueMovies{indexMoviesTest(i,1)} '_' num2str(indexMoviesTest(i,4)) '_Trim' targetAzimuth '.mov'];
        if indexMoviesTest(i,3) == 0
            moviename2 = [devRootm filesep randomMovies{2} maskerAzimuth1 '.mov'];
            moviename3 = [devRootm filesep randomMovies{3} maskerAzimuth2 '.mov'];
        else
            moviename2 = [devRootm filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} maskerAzimuth1 '.mov'];
            moviename3 = [devRootm filesep fixedMaskerList{indexMoviesTest(i,1)*2} maskerAzimuth2 '.mov'];
        end
        
        for j = 1:numAns
            if j == 1
                theImageLocations{j} = [dirFaces filesep uniqueMovies{indexMoviesTest(i,1)} '_Trim_Cropped.png'];
            else
                theImageLocations{j} = [dirFaces filesep randomMovies{j} '_Cropped.png'];
            end
            if j < 4
                if j == 1
                    textLocations{(j*2)-1} = [transcriptDirUpdated filesep uniqueMovies{indexMoviesTest(i,1)} '_' num2str(indexMoviesTest(i,4)) '_Trim.txt'];
                else
                    textLocations{(j*2)-1} = [transcriptDir filesep randomMovies{j} '.txt'];
                end
                if j < 3
                    if j == 1
                        textLocations{j*2} = [transcriptDirUpdated filesep uniqueMovies{indexMoviesTest(i,1)} '_' num2str(indexMoviesTest(i,4)) '_Trim_False.txt'];
                    else
                        textLocations{j*2} = [transcriptDir filesep randomMovies{j} '_False.txt'];
                    end
                end
            end
        end
        
        if indexMoviesTest(i,3) == 1
            theImageLocations{2} = [dirFaces filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '_Cropped.png'];
            theImageLocations{3} = [dirFaces filesep fixedMaskerList{indexMoviesTest(i,1)*2} '_Cropped.png'];
            textLocations{3} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '.txt'];
            textLocations{4} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2-1} '_False.txt'];
            textLocations{5} = [transcriptDir filesep fixedMaskerList{indexMoviesTest(i,1)*2} '.txt'];
        end
        
        imageLocationsShuffled = theImageLocations(randperm(numel(theImageLocations)));
        findIndex = cellfun(@(x)isequal(x,theImageLocations{1}),imageLocationsShuffled);
        correctRespV(i) = find(findIndex);
        
        textLocationsShuffled = textLocations(randperm(numel(textLocations)));
        findIndex = cellfun(@(x)isequal(x,textLocations{1}),textLocationsShuffled);
        correctRespA(i) = find(findIndex);
        
        % If this doesn't work, create a video clip with white cross.
%         Screen('TextSize', currWinPtr, 90);
%         DrawFormattedText(currWinPtr, '+', 'center','center',[255,255,255]);
%         Screen('Flip', currWinPtr);
        
        % Start of cue
        cfg.Trigger1(i) = toc;
        if opTrigger == 1
            cfg.com.sendTrigger(9);
            %fprintf(s,200);
            %fprintf(s,251);
        end
        cue = Screen('OpenMovie',currWinPtr, audioCue);
        Screen('PlayMovie', cue, 1);
        tex1 = 1;
        
        %while ~KbCheck
            % Wait for next movie frame, retrieve texture handle to it
        while (tex1)
            tex1 = Screen('GetMovieImage', currWinPtr, cue);
            % Valid texture returned? A negative value means end of movie reached:
            if tex1<=0
                % We're done, break out of loop:
                break;
            end

            % Draw the new texture immediately to screen:
            Screen('DrawTexture', currWinPtr, tex1);
 
            % Update display:
            Screen('Flip', currWinPtr);

            % Release texture: 213
            Screen('Close', tex1);
        end
        
        Screen('PlayMovie', cue, 0);
        Screen('CloseMovie', cue);
        
        %fprintf(s,255);
        %WaitSecs(2);
        
        % Open movie file:
        movie1 = Screen('OpenMovie', currWinPtr, moviename1);
        
        if indexMoviesTest(i,5)
            movie2 = Screen('OpenMovie', maskerWinPtr1, moviename2);
            movie3 = Screen('OpenMovie', maskerWinPtr2, moviename3);
        end

        Priority(2);
        
        % Start of movies
        cfg.Trigger2(i) = toc;
        if opTrigger == 1
            cfg.com.sendTrigger(3);
            %fprintf(s,210);
            %fprintf(s,252);
        end
        
        % Start playback engine:
        Screen('PlayMovie', movie1, 1);
        if indexMoviesTest(i,5)
            Screen('PlayMovie', movie2, 1);
            Screen('PlayMovie', movie3, 1);
        end
        %fprintf(s,255); 
        tex1 = 1;
        tex2 = 1;
        tex3 = 1;
        % Playback loop: Runs until end of movie or keypress:
        %while ~KbCheck
        while (tex1 > 0 && tex2 > 0 && tex3 > 0)
            try
                % Wait for next movie frame, retrieve texture handle to it
                tex1 = Screen('GetMovieImage', currWinPtr, movie1);
                if indexMoviesTest(i,5)
                    tex2 = Screen('GetMovieImage', maskerWinPtr1, movie2);
                    tex3 = Screen('GetMovieImage', maskerWinPtr2, movie3);
                end
                % Valid texture returned? A negative value means end of movie reached:
                if (tex1 && tex2 && tex3) <=0
                    % We're done, break out of loop:
                    disp('Line Break');
                    break;
                end

                % Draw the new texture immediately to screen:
                if tex1 > 0
                    Screen('DrawTexture', currWinPtr, tex1);
                    
                    Screen('Close', tex1);
                end
                if indexMoviesTest(i,5)
                    if tex2 > 0
                        Screen('DrawTexture', maskerWinPtr1, tex2);
                        
                        Screen('Close', tex2);
                    end
                    if tex3 > 0
                        Screen('DrawTexture', maskerWinPtr2, tex3);
                        
                        Screen('Close', tex3);
                    end
                end
                
                Screen('Flip', currWinPtr);
                if indexMoviesTest(i,5)
                    Screen('Flip', maskerWinPtr1);
                    Screen('Flip', maskerWinPtr2);
                end

            catch ME
                sca;
                fprintf(1,'The identifier was:\n%s',ME.identifier);
                fprintf(1,'There was an error! The message was:\n%s',ME.message);
                fprintf(1,'Line%d',ME.stack.line);
                
                if tex1 > 0
                    Screen('DrawTexture', currWinPtr, tex1);
                    Screen('Close', tex1);
                end
                if indexMoviesTest(i,5)
                    if tex2 > 0
                        Screen('DrawTexture', maskerWinPtr1, tex2);
                        Screen('Close', tex2);
                    end
                    if tex3 > 0
                        Screen('DrawTexture', maskerWinPtr2, tex3);
                        Screen('Close', tex3);
                    end
                end
            end

            % Release texture: 213
%             Screen('Close', tex1);
%             if indexMoviesTest(i,5)
%                 Screen('Close', tex2);
%                 Screen('Close', tex3);
%             end
        end
        
        % Start of question
        cfg.Trigger3(i) = toc;
        if opTrigger == 1
            cfg.com.sendTrigger(5);
            %fprintf(s,220);
            %fprintf(s,253);
        end
        
        try 
            Screen('FillRect', cfg.windowPtr1,background,rect1);
    %         if indexMoviesTest(i,5)
                Screen('FillRect', cfg.windowPtr2,background,rect2);
                Screen('FillRect', cfg.windowPtr3,background,rect3);
    %         end
            Screen('Flip',cfg.windowPtr1);
    %         if indexMoviesTest(i,5)
                Screen('Flip',cfg.windowPtr2); 
                Screen('Flip',cfg.windowPtr3);
    %         end

            for j = 1:numAns
                theImage = imread(imageLocationsShuffled{j});
                rectCoorList(:,j) = [x2Coors(j), y2Coors(j),x1Coors(j), y1Coors(j)];
                textureList(j) =  Screen('MakeTexture', centerWinPtr, theImage);
            end 

            Screen('DrawTextures', centerWinPtr, textureList, [], rectCoorList);

            for k = 1:5
                Screen('DrawText',centerWinPtr,num2str(k),centerXCoors(k)-100,centerYCoors(k)-200,[255 255 255]);
            end
            Screen('Flip',centerWinPtr);
            %fprintf(s,255);
            % Stop playback:
            Screen('PlayMovie', movie1, 0);
            if indexMoviesTest(i,5)
                Screen('PlayMovie', movie2, 0);
                Screen('PlayMovie', movie3, 0);
            end
            % Close movie:
            Screen('CloseMovie', movie1);
            if indexMoviesTest(i,5)
                Screen('CloseMovie', movie2);
                Screen('CloseMovie', movie3);
            end

        catch e2
            save([devDir filesep 'response_3M_EEG_' subj '_' dncstr],'responsesA','correctRespA','responsesV','correctRespV','trialStopped','cfg');
            sca;
            fprintf(1,'The identifier was:\n%s',e2.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e2.message);
            fprintf(1,'Line%d',e2.stack.line);
        end
        cfg.stimEndTime = GetSecs;
        responsesV(i) = getResponse(cfg);
        
        Screen('Close',textureList);
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
        % end of question
        cfg.Trigger4(i) = toc;
        if opTrigger == 1
            cfg.com.sendTrigger(7);
            %fprintf(s,230);
            %fprintf(s,255);
        end
        
        % Remove this block for EEG
        %Screen('FillRect', centerWinPtr,background,centerRect);
        %Screen('Flip',centerWinPtr);
        %timeWait = 4 + 2*rand(1);
        %WaitSecs(timeWait);
        
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
                %fprintf(s,255);
                % Set the abort-demo flag.
                Screen('FillRect', centerWinPtr,background,centerRect);
                Screen('Flip',centerWinPtr);
                break;
            end
            if (keyIsDown==1 && keyCode(cfg.esc))
                % Set the abort-demo flag.
                trialStopped = i;
                save([devDir filesep 'response_3M_EEG_' subj '_' dncstr],'responsesA','correctRespA','responsesV','correctRespV','trialStopped','cfg');
                sca;
                break;
            end
        end
        Priority(2);
    end
    
    % Close Screen, we're done: 
    sca;
    dnc = clock;
    dncstr = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3)) '_' num2str(dnc(4)) num2str(dnc(5))];
    dncstr2 = [num2str(dnc(1)) num2str(dnc(2)) num2str(dnc(3))];
    
    if ithSec < numSec
        save([devDir filesep 'response_3M_EEG_' subj '_' dncstr2 '_Temp'],'responsesA','correctRespA','responsesV','correctRespV','cfg');
    else
        save([devDir filesep 'response_3M_EEG_' subj '_' dncstr],'responsesA','correctRespA','responsesV','correctRespV','cfg');
    end
    
catch e
    Screen('Close',cfg.windowPtr1);
    Screen('Close',cfg.windowPtr2);
    Screen('Close',cfg.windowPtr3);
    save([devDir filesep 'response_3M_EGG_' subj '_' dncstr],'responsesA','correctRespA','responsesV','correctRespV','trialStopped','cfg');
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