load images;face=images.andrea;face=face*sqrt(1/var(face(:)));nv=[.001,.01,.1];numnz=length(nv);thresholdguess=3*nv/40;numvalues=7;stimpix=256;for kk=1:numnz	tmp=thresholdguess(kk)/sqrt(10);	values(kk,:)=logspace(log10(tmp),log10(10*tmp),numvalues); % set (n=numvalues) of log-spaced values centered on thresholdguess	constimrec(kk)=constimInit(values(kk,:),1); % init the constantstimulus struct	constimrec(kk).appspec=nv(kk);	% attached noise variance to app-specific fieldend;% to add calibration and luminance stufffor kk=1:numnz	nzvar=constimrec(kk).appspec;	% noise variance	[stim,nzseed]=noise2d(stimpix,nzvar,-1,1,0);	noiseVariance=var(stim(:))	for v=1:numvalues	%nzvar=constimrec(kk).appspec;	% noise variance	%[stim,nzseed]=noise2d(stimpix,nzvar,-1,1,0);	constimrec(kk).curvalue=constimrec(kk).values(v);	curStimVariance=constimrec(kk).curvalue; % get the stimulus variance for the current method-of-constant-stimuli record	tmpface=face*sqrt(curStimVariance); % this formula works because the faces have a variance of 1	faceVariance=var(tmpface(:))	stim=stim+tmpface;	stimVariance=var(stim(:))	figure	imshow(imscale(stim));	hold on;endend;