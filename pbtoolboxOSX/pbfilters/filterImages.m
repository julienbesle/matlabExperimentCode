
load images;

%tmpface=noise2d(256,.01,-1,1);
tmpface=images.andrea;
%filter1=bpfilter(2,20,256);
%filter2=bpfilter(4,20,256);
%filter3=bpfilter(8,20,256);
filter4=bpfilter(25,30,256);
filter5=bpfilter(10,15,256);
filter6=bpfilter(89,90,256);


%tmpface01=bpimage(tmpface,filter1,0);
%tmpface02=bpimage(tmpface,filter2,0);
%tmpface03=bpimage(tmpface,filter3,0);
tmpface04=bpimage(tmpface,filter4,0);
tmpface05=bpimage(tmpface,filter5,0);
tmpface06=bpimage(tmpface,filter6,0);



% figure;
% imshow(scale(tmpface04));
% figure;
% imshow(scale(tmpface05));
% figure;
% imshow(scale(tmpface06));
% figure;
% imshow(scale(tmpface04));
% figure;
% imshow(scale(tmpface05));
tmptest=tmpface04+tmpface05+tmpface06;
figure; imshow(scale(tmptest));

