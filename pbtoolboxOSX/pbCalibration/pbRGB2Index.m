function theIndex = pbRGB2Index(RGB,rgbMatrix)
%
% function theIndex = pbRGB2Index(RGB,rgbMatrix)
% RGB : n x 3 matrix
% rgbMatryx : y x 3 matrix
%
% Looks up RGB in rgbMatrix and returns the corresponding row numbers.
%
% A warning is given if RGB is NOT matched exactly in rgbMatrix.
% In such cases, the function returns the index of the closest match (in terms of
% Euclidean distance). Note, this process is slow, so make sure that RGB
% exists in rgbMatrix if speed is important.
%

if nargin<2
    error('insufficient inputs to function');
end;

if (size(RGB,2)~=3) || (size(rgbMatrix,2)~=3)
	error('inputs must have 3 columns');
end;

n=size(RGB,1);
theIndex=zeros(n,1); % assumes RGB is a 3 colum matrix
for kk=1:n
	rgbtmp=RGB(kk,:);
    tmp=find(rgbMatrix(:,1)==rgbtmp(1)&rgbMatrix(:,2)==rgbtmp(2)&rgbMatrix(:,3)==rgbtmp(3));
    if (isempty(tmp)==1)
        diff=rgbMatrix-rgbtmp;
        ss = sum((diff.^2),2);
        [y,i]=min(ss);
        tmp=rgbMatrix(i,:);
        warning('Exact matches to some RGB values were not found. Returned closest RGB values instead.');
    else
        theIndex(kk)=tmp;
    end;
end;





