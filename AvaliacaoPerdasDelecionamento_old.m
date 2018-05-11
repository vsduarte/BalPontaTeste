%
%   Avaliação das perdas
%

%---> Leitura da Função de perdas por simulação adotadas no PEN 2014
%path = uigetdir;
NomeArquivoPerdas = [path '/FuncaoPerdas.csv'];
FuncPerdas = dlmread(NomeArquivoPerdas,';',2,1);

%---> Cálculo das perdas - função adotada no PEN 2014
iper = 18;
x1 = 0:1:100;
for isis = 1:nsis
   a = 3*(isis-1) + 1;
   b = 3*(isis-1) + 2;
   c = 3*(isis-1) + 3;
   i = 1;
   for iEAR = x1
      Perdas(i,isis) = ...
         FuncPerdas(iper,a)*iEAR^2 + ...
         FuncPerdas(iper,b)*iEAR + ...
         FuncPerdas(iper,c);
      i = i + 1;
   end
end

%---> Gráficos
close all

isis = 3;
plot(x1,Perdas(:,isis),'r','linewidth',2.5)
hold on;
x = 20;
iPerdas = Perdas(x,isis);
a = 3*(isis-1) + 1;
b = 3*(isis-1) + 2;
c = 3*(isis-1) + 3;
line([x x+5],[iPerdas iPerdas*1.1],'LineWidth',1,'color','r')
% text(x+5,iPerdas*1.12,...
%     [' ' num2str(FuncPerdas(iper,a),'%.f') ...
%     'e^{' num2str(FuncPerdas(iper,b)/100,'%.5f') '   EAR} +'...
%      ' ' num2str(FuncPerdas(iper,c),'%.3f') ...
%      'e^{' num2str(FuncPerdas(iper,d)/100,'%.6f') '   EAR}'],...
%     'FontSize',10,'color','r')
text(x+5,iPerdas*1.12,...
    ['Perdas considerando função de perdas por simulação'],...
    'FontSize',10,'color','r')

 title(Sistema(isis).nome)
 xlabel('Volume (%)');
 ylabel('Perda (MW)');
 
%---> Estimativa das perdas, considerando operação em paralelo
volume = 0:100;
PotDisp = zeros(size(volume,2),1);
PerdaDepParalelo = zeros(size(volume,2),1);
for iusi = 1:nusi
   if(ConfHd(iusi).subsistema == isis)
      i = 1;
      for iVolume = volume
           PotDisp(i) = PotDisp(i) + ...
              CalcPdisp(DadoCadastroUsina(iusi),...
                        iVolume/100,...
                        ConfHd(iusi).NumMaq(:,iper),...
                        ConfHd(iusi).CFuga(iper));
           i = i + 1;
      end
   end
end

for i = 1:size(volume,2)
   PerdaDepParalelo(i) = PerdaDepParalelo(i) + PinstH(iper,isis) - PotDisp(i);
end

%---> Gráficos

plot(volume,PerdaDepParalelo,'b','linewidth',2.5)
x = 50;
iPerdas = PerdaDepParalelo(x);
line([x x+5],[iPerdas iPerdas*1.1],'LineWidth',1,'color','b')
text(x+5,iPerdas*1.12,...
    ['Perdas considerando operação em paralelo'],...
    'FontSize',10,'color','b')
YTick = get(gca,'YTick');
set(gca,...
    'XGrid','on',...
    'YMinorGrid','on',...
    'YGrid','on',...
    'YTick',YTick,...
    'YTickLabel',YTick)

