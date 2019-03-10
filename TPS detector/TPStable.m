function informationTable=TPStable(TPSbits)
informationTable{1,1} = 'Synch bits';
switch num2str(TPSbits(2:17))
    case '0  0  1  1  0  1  0  1  1  1  1  0  1  1  1  0'
        informationTable{1,2} = 'synched to frame 1 or 3';
    case '1  1  0  0  1  0  1  0  0  0  0  1  0  0  0  1'
        informationTable{1,2} = 'synched to frame 2 or 4';
    otherwise
        informationTable{1,2} = 'NOLL';
end
informationTable{2,1} = 'Length Indicator';
switch num2str(TPSbits(18:23))
    case '0  1  0  1  1  1'
        informationTable{2,2} = 'Cell Id NOT Transmitted';
    case '0  1  1  1  1  1'
        informationTable{2,2} = 'Cell Id is Transmitted';
    otherwise
        informationTable{2,2} = 'NOLL';
end
informationTable{3,1} = 'FrameNumber';
switch num2str(TPSbits(24:25))
    case '0  0'
        informationTable{3,2} = 'frame 1';
    case '0  1'
        informationTable{3,2} = 'frame 2';
    case '1  0'
        informationTable{3,2} = 'frame 3';
    case '1  1'
        informationTable{3,2} = 'frame 4';
end
informationTable{4,1} = 'modulation scheme';
switch num2str(TPSbits(26:27))
    case '0  0'
        informationTable{4,2} = 'QPSK';
    case '0  1'
        informationTable{4,2} = '16QAM';
    case '1  0'
        informationTable{4,2} = '64QAM';
    case '1  1'
        informationTable{4,2} = 'Reserved';
end
informationTable{5,1} = 'signaling format';
switch num2str(TPSbits(28:30))
    case '0  0  0'
        informationTable{5,2} = 'Non hierarchical';
        hierarchicalFlag =0;
    case '0  0  1'
        informationTable{5,2} = '1';
        hierarchicalFlag =1;
    case '0  1  0'
        informationTable{5,2} = '2';
        hierarchicalFlag =1;
    case '0  1  1'
        informationTable{5,2} = '3';
        hierarchicalFlag =1;
    otherwise
        informationTable{5,2} = 'Reserved';
        hierarchicalFlag =0;
end
informationTable{6,1} = 'CodeRate';
switch num2str(TPSbits(31:33))
    case '0  0  0'
        informationTable{6,2} = '1/2';
    case '0  0  1'
        informationTable{6,2} = '2/3';
    case '0  1  0'
        informationTable{6,2} = '3/4';
    case '0  1  1'
        informationTable{6,2} = '5/6';
    case '1  0  0'
        informationTable{6,2} = '7/8';
    otherwise
        informationTable{6,2} = 'Reserved';
end
if hierarchicalFlag ==1
    switch num2str(TPSbits(34:36))
    case '0  0  0'
        informationTable{6,3} = '1/2';
    case '0  0  1'
        informationTable{6,3} = '3/2';
    case '0  1  0'
        informationTable{6,3} = '3/4';
    case '0  1  1'
        informationTable{6,3} = '5/6';
    case '1  0  0'
        informationTable{6,3} = '7/8';
    otherwise
        informationTable{6,3} = 'Reserved';
    end
end
informationTable{7,1} = 'Guard Interval';
switch num2str(TPSbits(37:38))
    case '0  0'
        informationTable{7,2} = '1/32';
    case '0  1'
        informationTable{7,2} = '1/16';
    case '1  0'
        informationTable{7,2} = '1/8';
    case '1  1'
        informationTable{7,2} = '1/4';
end
informationTable{8,1} = 'Mode';
switch num2str(TPSbits(39:40))
    case '0  0'
        informationTable{8,2} = '2K';
    case '0  1'
        informationTable{8,2} = '8K';
    case '1  0'
        informationTable{8,2} = '4K';
    case '1  1'
        informationTable{8,2} = 'Reserved';
end
