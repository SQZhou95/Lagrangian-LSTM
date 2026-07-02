function [W,pd_new] = get_w_Burr(T,adj)
pd = fitdist(T,'Burr');

Mode = ((pd.c-1)/(pd.k*pd.c+1))^(1/pd.c);
pd_new.alpha = pd.alpha;
pd_new.c = pd.c/adj;
pd_new.k = (Mode^(-pd_new.c)*(pd_new.c-1)-1)/pd_new.c;
pd_new = makedist('Burr',pd_new.alpha,pd_new.c,pd_new.k);

W = 1./pdf(pd_new,T);

ratio2min = W/min(W);
W(ratio2min>20) =20*min(W);