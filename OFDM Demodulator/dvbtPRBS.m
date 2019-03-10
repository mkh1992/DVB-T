%PRBS
function PRBSequence=dvbtPRBS(numOut)
ini = ones(1,11);
PRBSequence = zeros(1,numOut);
for i = 1 : numOut
    PRBSequence(i) = ini(11);
    temp = xor(ini(11),ini(9));
    ini  = circshift(ini,1);
    ini(1) = temp;
end