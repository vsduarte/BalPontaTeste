close all

isis = 3;
dado = squeeze(pdisp_sist_rev(9:60,isis,:))';
X = mean(dado);
E = std(dado);
L = quantile(dado,.05);
U = quantile(dado,.95);

errorbar(1:size(dado,2),X,1.96*E);
