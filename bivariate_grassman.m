%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute bivariate connectivity Grassmann paper Hindriks et al., 2024

function [fc, f] = bivariate_grassman(data,mlag,S)

tic
fc = zeros(size(data,1),size(data,1));
k = 1;
f = zeros(size(data,1)^2-size(data,1),mlag);
for x1 = 1: size(data,1)
    for x2 = 1: size(data,1)
        if x1~=x2
            [fc(x1,x2), f(k,:)]= invariant_features_bivariate_v2(data(x1,:),data(x2,:),mlag,S);
            k = k+1;
        end
    end
    
end
time = toc;
fprintf('done computing fc %d \n',round(time))
end

