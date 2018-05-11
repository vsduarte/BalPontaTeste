%
%   Avaliação das perdas
%

%---> Leitura da Função de perdas por simulação adotadas no PEN 2014
%path = uigetdir;
NomeArquivoPerdas = [path '/FuncaoPerdas.csv'];
FuncPerdas = dlmread(NomeArquivoPerdas,';',2,1);

%---> Cálculo das perdas - função adotada no PEN 2015
iper = 18;
isis = 4;

x1 = 0:1:100;
for jsis = 1:nsis
   a = 3*(jsis-1) + 1;
   b = 3*(jsis-1) + 2;
   c = 3*(jsis-1) + 3;
   i = 1;
   for iEAR = x1
      Perdas(i,jsis) = ...
         FuncPerdas(iper,a)*iEAR^2 + ...
         FuncPerdas(iper,b)*iEAR + ...
         FuncPerdas(iper,c);
      i = i + 1;
   end
end

 %---> Estimativa das perdas, considerando operação em paralelo
volume = x1;
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
close all
figure; hold on;

%--->  Perda por simulação
plot(x1,Perdas(:,isis),'r','linewidth',2.5)
x = 20;
iPerdas = Perdas(x,isis);
a = 3*(isis-1) + 1;
b = 3*(isis-1) + 2;
c = 3*(isis-1) + 3;
line([x x+5],[iPerdas iPerdas*1.1],'LineWidth',1,'color','r')
text(x+5,iPerdas*1.12,...
    ['Perdas considerando função de perdas por simulação'],...
    'FontSize',10,'color','r')

%--->  Perda em paralelo
plot(volume,PerdaDepParalelo,'b','linewidth',2.5)
x = 50;
iPerdas = PerdaDepParalelo(x);
line([x x+5],[iPerdas iPerdas*1.1],'LineWidth',1,'color','b')
text(x+5,iPerdas*1.12,...
    ['Perdas considerando operação em paralelo'],...
    'FontSize',10,'color','b');

ax1 = gca; 
YTick = ax1.YTick;
ax1.XGrid = 'on';
ax1.YGrid = 'on';
ax1.YMinorGrid = 'on';
ax1.YTickLabel = YTick;
ax1.XLim = [0 100];

title(Sistema(isis).nome)
xlabel('Volume (%)');
ylabel('Perda (MW)');
 
%---> Histograma
% volume = 0:4:100;
% ear_mes = squeeze(EAR(iper,isis,:));
% histograma = hist(ear_mes,volume);
% area(volume,histograma * ax1.YLim(2)*(1/4) / max(histograma),...
%  'FaceAlpha',0.2);

ytick_sec = YTick / Mercado(isis,iper) * 100;
ax2 = axes('Position',ax1.Position,...
    'YAxisLocation','right',...
    'XTick',[],...
    'Color','none');
 ax2.YLim = [min(ytick_sec) max(ytick_sec)];
 ax2.YTick = ytick_sec;
 ax2.YTickLabel = sprintf('%4.1f\n',ytick_sec);
 ax2.YLabel.String = 'Perda (% da Demanda)';
 