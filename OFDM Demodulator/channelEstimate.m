% Channel Estimate
function [coefficients]=channelEstimate(ofdmSymbols,mode,symbolNumber)
persistent PRBSequence SPC H Hmem
if symbolNumber == -1
        switch mode
        case 2048
            H = ones(1,1705);
            Hmem = zeros(1,1705);
        case 8192
            H = ones(1,6817);
            Hmem = zeros(1,6817);
        end
else  
    %% Continual pilots and PRBS
    if isempty(PRBSequence)
        switch mode
            case 2048
                numOut = 1705;
            case 8192
                numOut = 6817;
        end

        ini = ones(1,11);
        PRBSequence = zeros(numOut,1);
        for i = 1 : numOut
            PRBSequence(i) = ini(11);
            temp = xor(ini(11),ini(9));
            ini  = circshift(ini,1);
            ini(1) = temp;
        end
        PRBSequence=4/3*2*(1/2-PRBSequence);
    end
    %% location of Scattered pilot Cells
    if isempty(SPC)
        switch mode
            case 2048
                pmax = ceil(1705/12)+1;
                for symNum = 0:3
                    for p =0:pmax
                        SPC{symNum+1,1}(p+1,1) = 3*symNum+12*p+1;
                    end
                    SPC{symNum+1,1}=SPC{symNum+1,1}(SPC{symNum+1,1}<=1705);
                end
            case 8192
                pmax = ceil(6817/12)+1;
                for symNum = 0:3
                    for p =0:pmax
                        SPC{symNum+1,1}(p+1,1) = 3*symNum+12*p+1;
                    end
                    SPC{symNum+1,1}=SPC{symNum+1,1}(SPC{symNum+1,1}<=6817);
                end
        end
    end
    index = SPC{mod(symbolNumber,4)+1};
    Hmem(index) = (ofdmSymbols(index))./PRBSequence(index);
    if  Hmem(10) ~=0
        H = interp1(1:3:max(SPC{1,1}),Hmem(1:3:max(SPC{1,1})),1:1:max(SPC{1,1}),'spline');
        %H = smooth(H,200).';
    end
end
coefficients = H;

