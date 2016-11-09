function [norm,w,k,Dist,D]=dtwNEW(t,r,sigma)
% DA SISTEMARE
%Dynamic Time Warping Algorithm
%norm is the normalized distance between t and r
%Dist is unnormalized distance between t and r
%D is the accumulated distance matrix
%k is the normalizing factor
%w is the optimal path
%t is the vector you are testing against
%r is the vector you are testing
[rows,N]=size(t);
[rows,M]=size(r);
%[N,M] ---> model vector, to test vector
for n=1:N
	for m=1:M
        % Euclidean point-to-point distance: d(n,m)=(t(n)-r(m))^2;
        % Mahalanobis point-to-point distance
        d(n,m) = (transpose(t(:,n)-r(:,m)))*inv(sigma(:,:,m))*(t(:,n)-r(:,m));
	end
end
D=zeros(size(d));
D(1,1)=d(1,1);

for n=2:N
	D(n,1)=d(n,1)+D(n-1,1);
end
for m=2:M
	D(1,m)=d(1,m)+D(1,m-1);
end
for n=2:N
	for m=2:M
        D(n,m)=d(n,m)+min([D(n-1,m),D(n-1,m-1),D(n,m-1)]);
	end
end

Dist=D(N,M); % Minimum accumulated distance (forward recursion)
n=N;
m=M;
k=1;
w=[];

% Backward recursion, choose the 
w(1,:)=[N,M];

while ((n+m)~=2)
	if (n-1)==0
        m=m-1;
	elseif (m-1)==0
        n=n-1;
    else 
        [values,number]=min([D(n-1,m),D(n,m-1),D(n-1,m-1)]);
        switch number
            case 1
                n=n-1;
            case 2
                m=m-1;
            case 3
                n=n-1;
                m=m-1;
        end
	end
	k=k+1;
	w=cat(1,w,[n,m]);
end
norm = Dist/k;

% % DISPLAY THE RESULTS
% % % optimal path
% % ascissa = k:-1:1;
% % figure,
% %     plot(ascissa,w);
% %     title('Optimal warping path');
% % comparison between the acceleration patterns (x axis only)
% for i=1:1:k
%     norm_t(i) = t(1,w(i,1));
%     norm_r(i) = r(1,w(i,2));
% end
% figure,
%     % before DTW
%     subplot(2,1,1);
%     plot(t(1,:),'b');
%     hold on;
%     plot(r(1,:),'r');
%     title('acceleration curves - pre DTW');
%     % after DTW
%     subplot(2,1,2);
%     plot(k:-1:1,norm_t,'b');
%     hold on;
%     plot(k:-1:1,norm_r,'r');
%     title('acceleration curves - post DTW');