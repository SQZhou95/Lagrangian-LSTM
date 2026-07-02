function a = weighted_mean(x,w,dim)
id_NaN = isnan(x.*w);
w(id_NaN) = NaN;
sum_tmp = sum(x.*w,dim,'omitnan');
a = sum_tmp./sum(w,dim,'omitnan');
a(all(id_NaN,dim)) = NaN;
