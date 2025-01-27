function calibrationRecord=pbCalibrateBITS(colorNumber)
%
% function
% calibrationRecord=pbCalibrateBITS(colorNumber,doPelliFit)
%


% Prevents MATLAB from reprinting the source code when the program runs.
echo off


% For an explanation of the try-catch block, see the section "Error Handling"
% at the end of this document.
try
    whichScreen = max(Screen('Screens'));
    bkgrndBITSnumber=12000;
    portNumber=1;
    reps=2;
    if(exist('colorNumber','var')==1)
        if (length(colorNumber)<2)
            dpf=0; % dpf : do Pelli Fit
        else
            dpf=1;
        end;
    else
        dpf=1;
    end;
    stimpix=512;
    alldone=0;
    while (alldone==0)
        gotone=0;
        while (gotone==0)
            fprintf('\tCalibration Parameters:\n');
            fprintf('\t1... screen number = %i\n',whichScreen);
            fprintf('\t2... port number = %i\n',portNumber);
            fprintf('\t3... stimulus size (pixels) = %i\n',stimpix);
            if (dpf==1)
                fprintf('\t4... fit pelli function to data? YES\n');
            else
                fprintf('\t4... fit pelli function to data? NO\n');
            end;   
            fprintf('\t5... reps = %i\n',reps);
            fprintf('\td... do calibration\n');
            fprintf('\tx... exit\n');
            theInput=lower(input(sprintf('\t>> '),'s'));
            gotone=ismember(theInput,'12345dx');
        end; % while(gotone)
        switch theInput
            case '1'
                tmp = input(sprintf('\t screen number >> '));
                if isnumeric(tmp)
                    whichScreen=round(abs(tmp));
                end;
            case '2'
                tmp = input(sprintf('\t port number >> '));
                if isnumeric(tmp)
                    portNumber=round(abs(tmp));
                end;
            case '3'
                tmp = input(sprintf('\t stimulus size (pixels) >> '));
                if isnumeric(tmp)
                    stimpix=round(abs(tmp));
                end;
            case '4'
                dpf=not(dpf);
    %                     case '4'
    %                         tmp = input(sprintf('\t background BITS number >> '));
    %                         if isnumeric(tmp)
    %                             bkgrndBITSnumber=round(abs(tmp));
    %                         end;
            case '5'
                tmp = input(sprintf('\t number of repetitions >> '));
                if isnumeric(tmp)
                    reps=round(abs(tmp));
                end;
            case 'd'
                alldone=1;
            case 'x'
                fprintf('calibration procedure aborted by user\n');
                calibrationRecord=NaN;
                return;

        end; % switch theInput
    end; % while alldone

    whiteBITSnumber=pbMaxBITSmono;
    blackBITSnumber= 0;
    grayBITSnumber= round(0.5 * whiteBITSnumber);
    inc=whiteBITSnumber-grayBITSnumber;

%     if (exist('whichScreen')==0)
%         % Find out how many screens and use largest screen number.
%         whichScreen = max(Screen('Screens'));
%         fprintf('No screen number provided. Using %g as default.\n',whichScreen);
%     end;
% 
% 
%     if (exist('bkgrndBITSnumber')==0)
%         fprintf('No background provided. Will use 12000 as default.\n');
%         bkgrndBITSnumber=12000;
% 
%     end;
%    
%     if (exist('portNumber')==0)
%         fprintf('No port number provided. Will use 1 as default.\n');
%         portNumber=1;
%     end;
%     
%     if (exist('stimpix')==0)
%         fprintf('No stim size provided. Will use 256 as default.\n');
%         stimpix=256;
%     end;

    white = pbBits2MonoRGB(whiteBITSnumber);
    black = pbBits2MonoRGB(blackBITSnumber);
    gray = pbBits2MonoRGB(grayBITSnumber);
    bkgrndRGB = pbBits2MonoRGB(bkgrndBITSnumber);

    WaitSecs(0.5); % wait a moment...
    fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
    fprintf('(calibration)$ hit any key to continue...\n');
    WaitSecs(0.1);
    while(KbCheck==0)
	end;
    
    fprintf('\n(calibration)$ turn on the photometer...\n');
    fprintf('(calibration)$ hit any key to continue...\n');
    WaitSecs(0.1);
    while(KbCheck==0)
	end;
    fprintf('initializing photometer...\n');

	% ---------- Open Photometer ------
	retval = pb650init(portNumber);
    
	% ---------- Window Setup ----------
	% Opens a window.


	% Screen is able to do a lot of configuration and performance checks on
	% open, and will print out a fair amount of detailed information when
	% it does.  These commands supress that checking behavior and just let
    % the demo go straight into action.  See ScreenTest for an example of
    % how to do detailed checking.
% 	oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
%     oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
	
%     % Find out how many screens and use largest screen number.
%     whichScreen = max(Screen('Screens'));
    
	% Hides the mouse cursor
% 	HideCursor;
	
	% Get the list of screens and choose the one with the highest screen number.
	% Screen 0 is, by definition, the display with the menu bar. Often when 
	% two monitors are connected the one without the menu bar is used as 
	% the stimulus display.  Chosing the display with the highest dislay number is 
	% a best guess about where you want the stimulus displayed.  
	screens=Screen('Screens');

    % Find the color values which correspond to white and black.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true on OS X after we add other color depth modes.  
% 	white=WhiteIndex(whichScreen);
% 	black=BlackIndex(whichScreen);
%     gray=round((white+black)/2);
% 	if gray==white
% 		gray=black;
% 	end
% 	inc=white-gray;

	% Open a double buffered fullscreen window and draw a gray background 
	% to front and back buffers:
	[w,wrect]=Screen('OpenWindow',whichScreen, 0,[],32,2);
    
    
    
    % THE FOLLOWING STEP IS IMPORTANT.
    % make sure the graphics card LUT is set to a linear ramp
    % (else the encoded data will not be recognised by Bits++).
    % There is a bug with the underlying OpenGL function, hence the scaling 0 to 255/256.  
    % This demo will not work using a default gamma table in the graphics card,
    % or even if you set the gamma to 1.0, due to this bug.
    % This is NOT a bug with Psychtoolbox!
%     Screen('LoadNormalizedGammaTable',w,linspace(0,(255/256),256)'*ones(1,3));
    % =================================================================
    % ATTENTION!! NOT SURE THAT WE NEED OR SHOULD LOAD A LINEAR LUT
    % "linear_lut" should be replaced here with one giving the inverse
    % characteristic of the monitor.
    % =================================================================
    % restore the Mono++ overlay LUT to a linear ramp
%     linear_lut =  repmat(round(linspace(0, 2^16 -1, 256))', 1, 3);
%     BitsPlusSetClut(w,linear_lut);

    
    % get & record screen properties
    hz=Screen('NominalFrameRate', whichScreen);
    fprintf('>>> display frame rate (Hz) = %g\n',hz);
    pixelSize=Screen('PixelSize', whichScreen);
    fprintf('>>> pixel size = %g\n',pixelSize);
    [widthmm, heightmm]=Screen('DisplaySize', whichScreen);
    widthcm=widthmm/10;
    heightcm=heightmm/10;
    fprintf('>>> display size (cm)[width, height] = [%g,%g]\n >>> N.B. These numbers may be inaccurate; PLEASE CHECK!!\n',widthcm,heightcm);
    [widthPixels, heightPixels]=Screen('WindowSize', whichScreen);
    fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);
    
	Screen('FillRect',w, bkgrndRGB);
	Screen('Flip', w);
	Screen('FillRect',w, bkgrndRGB);
	Screen('Flip', w);
    
    center = [wrect(3) wrect(4)]/2;	% coordinates of screen center (pixels)
    fps=Screen('FrameRate',w);      % frames per second
    if(fps==0)
        fps=67;
        fprintf('WARNING: using default frame rate of %i Hz\n',fps);
    end;
    ifi=Screen('GetFlipInterval', w);






	  

	% ---------- Image Setup ----------
	stimrect=SetRect(0,0,stimpix,stimpix);
	destRect=CenterRect(stimrect,wrect);

%Stores the image in a two dimensional matrix.
%spot_size = stimpix;
%ss2 = stimpix/2;
%n=0:(stimpix-1);
%widthArray = (n-ss2)/ss2;
%
%Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
%the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
%and y = y(x0, y0) corresponds to the y-coordinate of element "i"
%[x y] = meshgrid(widthArray, widthArray);
%circularWindow = ( sqrt(x.^2 + y.^2)<1);
%
%tmp = abs(circularWindow-1);
%backgrnd = (gray+zeros(stimpix,stimpix)).*tmp;
%
%
%imageMatrix = gray+zeros(stimpix,stimpix,3);
%   imageMatrix(:,:,1)=backgrnd;
%   imageMatrix(:,:,2)=backgrnd;
%   imageMatrix(:,:,3)=backgrnd;
%imageMatrix(:,:,4)=circularWindow.*white;
	Screen('FillRect',w,bkgrndRGB,destRect);
	Screen('FillOval',w,[0 0 0],destRect);			
	vbl=Screen('Flip', w,1);
    fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');
    while(KbCheck==0)
	end;
    fprintf('taking measurements...\n');
    fprintf('HOLD DOWN ANY KEY TO ABORT...\n\n');
	
	waitframes = 2;
	Screen('FillRect', w, bkgrndRGB,destRect);
	vbl=Screen('Flip', w,1);
 	if(exist('colorNumber','var')==0)
        colorNumber=round([(0:500:1500),(2000:200:5000),(5100:100:7000),(7050:50:10000),(10020:20:16350),pbMaxBITSmono]);
    end;
% 	colorNumber=round([(0:500:1500),(2000:200:5000),(5100:100:7000),(7050:50:16350),pbMaxBITSmono]);
%  	colorNumber=round([(2000:2000:16000),pbMaxBITSmono]);
	calData=zeros(1,8);

    curRGB=1;
%     rgb=[0 0 0];
%     Screen('FillRect',w,bkgrndRGB,destRect);
%     Screen('FillOval',w,rgb,destRect);
%     vbl=Screen('Flip', w,1);
%     WaitSecs(0.1);
%     [qual,L,U,V]=pb650Measure;
%     calData(curRGB,:)=[rgb(1),rgb(2),rgb(3),qual,L,U,V,0];
%     curRGB=curRGB+1;

        
		for jj=1:length(colorNumber)
			rgb=[0 0 0];
			rgb=pbBits2MonoRGB(colorNumber(jj));
            [qual,L,U,V] = getMeasurement(w,bkgrndRGB,rgb,destRect,reps);
            % Switch to realtime-priority to reduce timing jitter and interruptions
            % caused by other applications and the operating system itself:
%             Priority(MaxPriority(w));

%  			Screen('FillRect',w,bkgrndRGB);
% 			Screen('FillOval',w,rgb,destRect);
% 			vbl=Screen('Flip', w,1);
%             WaitSecs(0.2);
%             [qual,L,U,V]=pb650Measure;
%             WaitSecs(0.2);
%             [qual2,L2,U2,V2]=pb650Measure;
%             L = (L+L2)/2;
%             U = (U+U2)/2;
%             V = (V+V2)/2;
            calData(curRGB,:)=[rgb(1),rgb(2),rgb(3),qual,L,U,V,colorNumber(jj)];
            curRGB=curRGB+1;
            fprintf('RGB = [%3i,%3i,%3i]; luminance = %6.2f; bitsnumber = %g\n',rgb(1),rgb(2),rgb(3),L,colorNumber(jj));
            WaitSecs(0.1);
% 			% Colors the entire window gray.
% 			Screen('FillRect', w, [0 0 0],destRect);
% 			vbl=Screen('Flip', w,2+.5);
            
            
%             % Shutdown realtime scheduling:
%             finalprio = Priority(0);

			if KbCheck
                pb650close;
                Screen('CloseAll');
                ShowCursor;
                fprintf('calibration procedure aborted by user\n');
				break;
			end;
		end;

	
	pb650close;
	% ---------- Window Cleanup ---------- 

	% Closes all windows.
	Screen('CloseAll');
	 
	% Restores the mouse cursor.
	ShowCursor;
    calRec.calType='BITS';
    calRec.date=datestr(now);
    calRec.stimsize = stimpix;
    calRec.displaypixels =  [widthPixels, heightPixels];
    calRec.framerate = hz;
    calRec.displaycm =  [widthcm, heightcm];
    calRec.pixelsize = pixelSize;    
    calRec.backgroundRGB = bkgrndRGB;
    calRec.backgroundBITS = bkgrndBITSnumber;
    calRec.caldata=calData;
    calRec.lmaxminave=pbBITS2Lum([pbMaxBITSmono,0,bkgrndBITSnumber],pbExtractLuminanceValues(calRec,0),pbExtractBITSnumbers(calRec,0));
    fprintf('(calibration)$ saving data in curCalRecTmpFile.mat\n');
    save 'curCalRecTmpFile' calRec;
    if dpf
        fprintf('(calibration)$ fitting pelli functions to data...\n');
        calibrationRecord=pbFitBITSData(calRec);
    else
        calibrationRecord=calRec;
    end;
    fprintf('(calibration)$ saving calibrationRecord in curCalRecord.mat\n');
    save 'curCalRecord' calibrationRecord;
    fprintf('(calibration)$ information about screen size may be incorrect... PLEASE CHECK!\n');
    


  

%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
catch
   
	% ---------- Error Handling ---------- 
	% If there is an error in our code, we will end up here.

	% The try-catch block ensures that Screen will restore the display and return us
	% to the MATLAB prompt even if there is an error in our code.  Without this try-catch
	% block, Screen could still have control of the display when MATLAB throws an error, in
	% which case the user will not see the MATLAB prompt.
	Screen('CloseAll');

	% Restores the mouse cursor.
	ShowCursor;
    
%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

	% We throw the error again so the user sees the error description.
	psychrethrow(psychlasterror);

end
    function [qual,L,U,V] = getMeasurement(w,bkgrndRGB,rgb,destRect,reps)
        Priority(MaxPriority(w));
        Screen('FillRect',w,bkgrndRGB);
        Screen('FillOval',w,rgb,destRect);
        vbl=Screen('Flip', w,1);
        WaitSecs(0.2);
        Lm=zeros(reps,1);
        Um=zeros(reps,1);
        Vm=zeros(reps,1);
        qualm=zeros(reps,1);
        for kk=1:reps
            WaitSecs(0.2);
            [qualm(kk),Lm(kk),Um(kk),Vm(kk)]=pb650Measure;
        end;
        qual=min(qualm);
        L=mean(Lm);
        U=mean(Um);
        V=mean(Vm);
        finalprio = Priority(0);
    end

    function calFitRecord=pbFitBITSData(calRecord)

        caldata=calRecord.caldata;
        if (size(caldata,1)<2)
            calFitRecord=calRecord;
            calFitRecord.ABKG=NaN;
            calFitRecord.calmatrix=NaN;
            warning('Insufficient points to fit pelli function');
        else
            
            bitsNumbers = caldata(:,8);
            lumValues = caldata(:,5);
            % initial parameters
            alpha = min(min(caldata(:,5)));
            beta = .01;
            kappa = .01;
            gamma = 2;
            initcoeffs = [alpha beta kappa gamma];

            % fits
            coeffs = pbPelliFit(bitsNumbers,lumValues,initcoeffs);

            bn = 0:pbMaxBITSmono;
            bn = bn';
            rgb = pbBits2MonoRGB(bn);
            L = pbPelliPower(coeffs,bn);

            % final calibration plot
            plot(bn,L,'k-');
            ylabel('Luminance (cd/m^2)');
            xlabel('Index');
            title('Look-Up Table');		

            drawnow;


            calFitRecord=calRecord;
            calFitRecord.ABKG=coeffs;
            calFitRecord.calmatrix=[rgb,L,bn];
        end;


    end


end
