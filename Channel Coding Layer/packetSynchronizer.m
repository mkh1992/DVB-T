%packetSynchronizer
function curser = packetSynchronizer(toOuterInterleaver)
header  = 2*[0 1 0 0 0 1 1 1]'-1;
headerC = 2*[1 0 1 1 1 0 0 0]'-1;
z= zeros(8*203,1);
syncwin = [headerC;z;header;z;header;z;header;z;header;z;header;z;header;z;header;z];
pocketSync  =conv(2*toOuterInterleaver-1, syncwin(end:-1:1));
[~,maxind]=max(pocketSync);
curser = maxind-length(syncwin)+1;

