%muxer
function x=muxer(b,v)

switch v
    case 2
        x=b;
    case 4
        x=[b(:,1),b(:,3),b(:,2),b(:,4)];
    case 6
        x=[b(:,1),b(:,3),b(:,5),b(:,2),b(:,4),b(:,6)];
end
x=reshape(x',numel(x),1);
    