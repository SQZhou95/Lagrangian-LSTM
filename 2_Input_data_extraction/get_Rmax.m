function Rmax = get_Rmax(TrajLength)
% y = a*x^b (x > T_cr), T_cr is the critical backward time
% y = 5.5 (x <= T_cr)

T_cr = [16 6 1]; % Lower, middle, and upper
a = [0.1015 0.6856 5.5005];
b = [1.44 1.162 0.8563];

x = [0:1:24*TrajLength]';
Rmax = NaN(length(x),3);
for i = 1:3
    Rmax(:,i) = a(i)*x.^b(i);
    Rmax(x<=T_cr(i),i) = 5.5;
end