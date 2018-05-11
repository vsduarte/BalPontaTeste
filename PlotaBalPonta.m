%
%   Imprime resultados do balanço de ponta probabilístico
%

%---> Anotações em 9/11/15
%
%  -> Reultados para o TCC
%     --------------------
% - Sobras e deficit por subsistema - OK
% - Permanência de sobras no SE/CO para JAN, FEV e MAR (Verão)
% - Fequencia de cenários com deficit
% - Probabilidades em intercâmbio

close all

%---> Preenche strings com o nome do mês
mes = ['jan';'fev';'mar';'abr';'mai';'jun';'jul';'ago';'set';'out';'nov';'dez'];
i = 0;
clear StrMes
for iano = anoi:anoi+nanos-1
   for imes = 1:12
      i = i + 1;
      StrMes(i,:) = [mes(imes,:) '/' sprintf('%2i',iano-2000)];
   end
end

%---> Preenche vetores com mapa de cores e com nome dos subsistemas e
%     inicializa algumas variáveis
close all;
NomeSistema = {Sistema.nome};
MapaCores = [119 147  60;
             149 179 215; 
              55  96 146; 
             255 192   0;
             85  142 213; 
             192  0    0] / 255;
MesInicio = 13;
MesFim = nper;

FonteEixos = 12;

% %---> Gráficos de sobras e déficit do SIN
% figure;
% set(gcf,'Name','Sobras e Deficit - SIN')
% colormap([1 0 0;0 1 0])
% DeficitSIN = sum(mean(Deficit,3));
% SobraSIN = sum(mean(Sobra,3));
% b = bar(-DeficitSIN(mesi:60),'r');
% hold on;
% bar(SobraSIN(mesi:60),'g')
% xlim([0 MesFim-MesInicio+2])
% set(gca,...
%       'XTick',[1:2:MesFim-MesInicio+1],...
%       'XTicklabel',StrMes([MesInicio:2:MesFim],:),...
%       'XTickLabelRotation',90);
% ylabel('MW')
% ytick = get(gca,'YTick');
% set(gca,'YTickLabel',ytick)
% 

%---> Permanências de sobras e deficit
% Balanco = Sobra - Deficit;
% isis = 2;
% for iano = 2017:2020
%    figure;
%    set(gcf,'Name',num2str(iano));
%    hold on;
%    for imes = 11:12
%       iper = (iano-anoi)*12 + imes;
%       plot(sort(squeeze(Balanco(isis,iper,:)),'descend'));
%    end
%    set(gca,'FontSize',16);
%    ylabel('MW');
%    xlabel('Frequência (%)')
%    ytick = get(gca,'YTick');
%    xtick = 0:10:nsim;
%    set(gca,...
%       'Ygrid','on',...
%       'Xgrid','on',...
%       'YTickLabel',ytick,...
%       'XTick',xtick,...
%       'XTickLabel',xtick/nsim*100)
%    legend(['NOV';'DEZ']);
% end

%---> Frequencia de Cenarios com Deficit
RiscoDeficitMensal = zeros(nsis,nper);
for isis = 1:4
   for iper = 1:nper
      for isim = 1:nsim
         if (Deficit(isis,iper,isim)>1e-5) 
            RiscoDeficitMensal(isis,iper) = ...
               RiscoDeficitMensal(isis,iper) + 1;
         end
      end
   end
   RiscoDeficitMensal(isis,:) = RiscoDeficitMensal(isis,:) / nsim * 100;
%---> Plota tabela com o risco de deficit   
   figure;
   set(gcf,'Name',['Risco Mensal Deficit - ',NomeSistema{isis}])
   b = bar(RiscoDeficitMensal(isis,MesInicio:60),'r');
   xlim([0 MesFim-MesInicio+2])
   ylim([0 100]);
   set(gca,...
         'Box','off',...
         'FontSize',FonteEixos,...
         'Ygrid','on',...
         'XTick',[1:2:MesFim-MesInicio+1],...
         'XTicklabel',StrMes([MesInicio:2:MesFim],:),...
         'XTickLabelRotation',90);
   ylabel('Risco de Déficit (%)')
   ytick = get(gca,'YTick');
   set(gca,'YTickLabel',ytick)
end

%numSeries = ones(nsis,60) * nsim;
numSeries = RiscoDeficitMensal / 100 * nsim;

%---> Gráficos de sobras e déficit dos Subsistemas
for isis = 1:4
   figure;
   set(gcf,'Name',['Sobras e Deficit - ',NomeSistema{isis}])
   colormap([1 0 0;0 1 0])
   DeficitSIN = mean(Deficit(isis,:,:),3);
   Def_cond(isis,:) = sum(squeeze(Deficit(isis,:,:)),2)' ./ numSeries(isis,:);
   SobraSIN = mean(Sobra(isis,:,:),3);
   b = bar(-DeficitSIN(MesInicio:60),'r');
   hold on;
   bar(SobraSIN(MesInicio:60),'g')
   xlim([0 MesFim-MesInicio+2])
   set(gca,...
         'Box','off',...
         'FontSize',FonteEixos,...
         'Ygrid','on',...
         'Xgrid','on',...
         'XTick',[1:2:MesFim-MesInicio+1],...
         'XTicklabel',StrMes([MesInicio:2:MesFim],:),...
         'XTickLabelRotation',90);
   ylabel('MW')
   ytick = get(gca,'YTick');
   set(gca,'YTickLabel',ytick)
end

%---> Probabiliade de Intecambio no limite
RiscoCongestionamento = zeros(nsis+nfic,nsis+nfic,nper);
for iper = 1:nper
   for isim = 1:nsim
      for jsis = 1:nsis+nfic
         for isis = 1:nsis
            iApontador = ApontadorIntercambio(jsis,isis);
            if (iApontador ~= 0)
               DifInterc = Intercambio(iApontador).capacidade(iper) - ...
                  Interc(jsis,isis,iper,isim);
               if(abs(DifInterc)<1e-3)
                  RiscoCongestionamento(jsis,isis,iper) = ...
                     RiscoCongestionamento(jsis,isis,iper) + 1;
               end
            end
         end
      end
   end
end

