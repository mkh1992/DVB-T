function [corrOut,varToAvg]= correlator(signal,guard,Ni)
costFunction = zeros(length(signal)-Ni-Ni*guard,1);
for  i=1:length(signal)-Ni-Ni*guard
    costFunction(i) = signal(i:(i+Ni*guard))'*signal((i+Ni):(i+Ni+Ni*guard));
end
corrOut=costFunction/(Ni*guard);
varToAvg = var(abs(corrOut))/mean(abs(corrOut));
    