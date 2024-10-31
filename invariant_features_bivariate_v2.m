
%INPUT: Time-domain (real-valued) signals x and y, the maximum lag mlag (in
%number of samples) to take into account, and S: S = 0 for the unsigned 
%measure and S = 1 for the signed measure. 
%OUTPUT: temporal irreversibility index
%Comment: If x and y are linearly dependent, the measure is not defined and
%returns zero.  

function [xi, f] = invariant_features_bivariate_v2(x,y,mlag,S)

%check that x and y are column vectors, and if not, make them column vectors. 
%(this is important for working with the cross-correlation function)
[a,b] = size(x);
if a<b 
    x = x';
end
[a,b] = size(y);
if a<b 
    y = y';
end

N = size(x,1); %number of observations


%f = zeros(mlag,1);
%for m=1:mlag
%    f(m) = (sum(x(1:N-m).*y(1+m:N)) - sum(y(1:N-m).*x(1+m:N)))/(N-m);
%end
%mean(f.^2)/det(cov([x y]))


%comment: I checked that the above expression gives the same answer to the
%expression below. 

g = xcorr(x,y,mlag,'unbiased'); %cross-covariance function between x and y 
f = g(mlag+2:end) - flipud(g(1:mlag)); %asymmetric part of the cross-covariance function

%connectivity measure 
if S == 0
    xi = sqrt(mean(f.^2)/det(cov([x y]))); %use for EEG/MEG data 
end
if S == 1
    xi = mean(f)/sqrt(det(cov([x y]))); %use for Utah data 
end





% if nargout == 0 
%     figure
%     subplot(2,1,1)
%     plot(-mlag:mlag,g,'k')
%     xlabel('Lag (number of samples)')
%     ylabel('Covariance (unbiased)')
%     grid on 
%     hold on 
%     plot([-mlag mlag],[0 0],'k')
%     subplot(2,1,2)
%     plot(0:mlag,f,'k')
%     xlabel('Lag (number of samples)')
%     ylabel('Asymmetry')
%     grid on
%     hold on 
%     plot([0 mlag],[0 0],'k')
% end
    