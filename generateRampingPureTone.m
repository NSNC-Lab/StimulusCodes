% generate pure tone with ramping
clear all;
close all
freq=2000;                    % frequency of the tone (Hz)

dur=2;                     % duration of the tone (seconds)

sampRate=44000;

nTimeSamples = dur*sampRate; %number of time samples

t = linspace(0,dur,nTimeSamples);

y = sin(2*pi*freq*t);

%sound(y,sampRate);  

ramp=linspace(0, 1, nTimeSamples/4);

ramp = [ramp ones(1,3/4*nTimeSamples)];

y2=y.*ramp;

filename = 'C:\Users\mn0mn\Documents\Stimuli\Practice\AudioFiles\pureTone2000Hz.wav';

audiowrite(filename,y2,sampRate);