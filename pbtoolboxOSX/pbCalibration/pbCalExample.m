calRec=pbReadCalibrationFile('ubu_1280_1024_75.mat'); % read a calibration file
% B=pbExtractBITSnumbers(calRec); % extract BITS++ numbers used during calibration
B=pbExtractNumbers(calRec); % extract numbers (i.e., look-up table indices) used during calibration
L=pbExtractLuminanceValues(calRec); % extract Luminance values measured during calibration
Lavg = calRec.lmaxminave(3); % luminance of background during calibration
C = (L-Lavg)./Lavg; % convert Luminance to Contrast
Cmax = C(end);
Cmin = C(1);
BITSavg = calRec.backgroundBITS; % bits number of background during calibration
BITSavg = pbLum2BITS(Lavg,L,B); % another way of getting the background BITS number via Lavg
BITSavg = pbLum2BITS(0,C,B); % yet another way, this time using Contrast instead of Luminance
RGBgrey = pbBits2MonoRGB(BITSavg); % convert bits number to RGB value

stimpix=256;
whichScreen = max(Screen('Screens'));
screens=Screen('Screens');
[w,wrect]=Screen('OpenWindow',whichScreen, 0,[],32,2);
stimrect=SetRect(0,0,stimpix,stimpix);
destRect=CenterRect(stimrect,wrect);

Priority(MaxPriority(w));

Screen('FillRect',w, RGBgrey);
Screen('DrawingFinished', w);
Screen('Flip', w);


Screen('FillRect',w, RGBgrey);
Screen('DrawingFinished', w);
Screen('Flip', w);
finalprio = Priority(0);

% make and display a gaussain noise stimulus:
nzsd = 0.2;
nz = nzsd.*randn(stimpix); % 512 x 512 noise array
tmp=find(nz > Cmax); nz(tmp)=Cmax;
tmp=find(nz < Cmin); nz(tmp)=Cmin;
nzBITS = pbLum2BITS(nz,C,B); % convert from contrast to BITS numbers
nzRGB = pbBits2MonoRGB(nzBITS); % convert to RGB
stimtex = Screen('MakeTexture',w, nzRGB);

Priority(MaxPriority(w));
Screen('DrawTexture', w, stimtex);
Screen('DrawingFinished', w);
Screen('Flip',w);
finalprio = Priority(0);

WaitSecs(2);
Priority(MaxPriority(w));
Screen('FillRect',w, RGBgrey);
Screen('DrawingFinished', w);
Screen('Flip', w);
finalprio = Priority(0);

curStim=zeros(stimpix,stimpix);
curBITS=curStim;
curRGB=zeros(stimpix,stimpix,3);
contrast=[0:0.01:0.5];
nc=length(contrast);
tt1=zeros(nc,1);
tt2=zeros(nc,1);
tt3=zeros(nc,1);
tic;
toc;
for kk=1:nc;
    tic;
    curStim=gabor(stimpix,8,contrast(kk),0,180*kk/nc,0.8);
    tt1(kk)=toc;
    tic;
    curBITS=pbLum2BITS(curStim,C,B);
    tt2(kk)=toc;
    tic;
    curRGB=pbBits2MonoRGB(curBITS);
    tt3(kk)=toc;
    Priority(MaxPriority(w));
    stimtex = Screen('MakeTexture',w, curRGB);
    Screen('FillRect',w, RGBgrey);
    Screen('DrawTexture', w, stimtex);
    Screen('DrawingFinished', w);
    Screen('Flip',w);
    finalprio = Priority(0);
end;
mean(tt1)
mean(tt2)
mean(tt3)


t=0:99;
contrast=0.4*(1+sin(2*pi*3*t/100));
nc=length(contrast);
tt1=zeros(nc,1);
tt2=zeros(nc,1);
tt3=zeros(nc,1);
tic;
toc;
theGabor = gabor(stimpix,8,1,0,0,0.8);
for kk=1:nc;
    tic;
    curStim=contrast(kk).*theGabor;
    tt1(kk)=toc;
    tic;
    curBITS=pbLum2BITS(curStim,C,B);
    tt2(kk)=toc;
    tic;
    curRGB=pbBits2MonoRGB(curBITS);
    tt3(kk)=toc;
    
    stimtex = Screen('MakeTexture',w, curRGB);
    Screen('FillRect',w, RGBgrey);
    Screen('DrawTexture', w, stimtex);
    Screen('DrawingFinished', w);
    Priority(MaxPriority(w));
    [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos]=Screen('Flip',w);
    finalprio = Priority(0);
    WaitSecs(0.01)
    
%     if (Missed>0)
%         fprintf('missed FLIP on stimulus %i; Beampos = %g *************\n',kk,Beampos);
%     else
%         fprintf('did not miss FLIP on stimulus %i; Beampos = %g\n',kk,Beampos);       
%     end;
end;
mean(tt1)
mean(tt2)
mean(tt3)


Screen('CloseAll');



