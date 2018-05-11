%
%   Avaliação das perdas
%

%---> Leitura dos armazenamentos
NomeArquivoEAR = [path '/Armazenamento.csv'];
EAR = zeros(nper,nsis);
dummy = dlmread(NomeArquivoEAR,';',2,1);
EAR(1:size(dummy,1),1:size(dummy,2)) = dummy;

%---> Leitura da Função de perdas por simulação adotadas no PEN 2014
NomeArquivoPerdas = [path '/FuncaoPerdas_eval.csv'];
FuncPerdas = dlmread(NomeArquivoPerdas,';',2,1);
PerdasPEN2014 = CalcPerdas(nsis,FuncPerdas,EAR);
 
%---> Estimativa das perdas, considerando operação em paralelo
PotDisp = zeros(nper,nsis);
PerdaDepParalelo = zeros(nper,nsis);
for iusi = 1:nusi
   isis = ApontadorSistema(ConfHd(iusi).subsistema);
   for iper = 1:nper
        PotDisp(iper,isis) = PotDisp(iper,isis) + ...
           CalcPdisp(DadoCadastroUsina(iusi),...
                     EAR(iper,isis)/100,...
                     ConfHd(iusi).NumMaq(:,iper),...
                     ConfHd(iusi).CFuga(iper));
   end
end

for iper = 1:nper
   for isis = 1:nsis
      PerdaDepParalelo(iper,isis) = PinstH(iper,isis) - PotDisp(iper,isis);
   end
end

%---> Gráficos
close all

for isis = 1:4
   figure;
   subplot(2,1,1)
   x = [5:60];
   y1 = PerdasPEN2014(5:60,isis);
   y2 = PerdaDepParalelo(5:60,isis);
   y3 = EAR(5:60,isis);
   plot([5:60],PerdasPEN2014(5:60,isis),'r','linewidth',2.5)
   hold on;
   plot([5:60],PerdaDepParalelo(5:60,isis),'b','linewidth',2.5)
   YTick = get(gca,'YTick');
   set(gca,...
       'XGrid','on',...
       'YMinorGrid','off',...
       'YGrid','on',...
       'YTick',YTick,...
       'YTickLabel',YTick,...
       'XTick',[5:4:60],...
       'XTicklabel',StrMes([5:4:60],:));
   xticklabel_rotate([],90);
%   title(Sistema(isis).nome)
%   xlabel('Mês');
   ylabel('Perda (MW)');
   legend('Função: PEN 2014','Função: Oper. em paralelo','Location','NorthEast');

   subplot(2,1,2)
   plot(x,y3,'k','linewidth',2.5);
   ylim([0 100]);
   YTick = get(gca,'YTick');
   set(gca,...
       'XGrid','on',...
       'YMinorGrid','off',...
       'YGrid','on',...
       'YTick',YTick,...
       'YTickLabel',YTick,...
       'XTick',[5:4:60],...
       'XTicklabel',StrMes([5:4:60],:));
   xticklabel_rotate([],90);
   xlabel('Mês');
   ylabel('Armazenamento (%)');

end


