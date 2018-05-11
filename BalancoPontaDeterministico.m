%
%   Solução do Balanço de Ponta Determinístico
%

fprintf('Calculando balanço de ponta determinístico...')
Sobra = zeros(nsis,nper);           % Inicializa a matriz de sobras
for iper = mesi:nper
   fprintf('   Período %2.2i',iper);
   [Deficit(:,iper), Excesso(:,iper), Interc(:,:,iper), GH(:,iper), ...
      GT(:,iper)] = resolveBP(nsis,nfic,GHmax(iper,:),GTmax(iper,:) ,...
      DispNS(:,iper),Mercado(:,iper),LimInterc(:,iper),GTmin(iper,:),...
      Sistema);
%---> Cálculo das sobras 
   for isis = 1:nsis
      Sobra(isis,iper) = round(max(0, ...
         (GHmax(iper,isis) + GTmax(iper,isis) + DispNS(isis,iper)) + ...
            squeeze(sum(Interc(:,isis,iper))) - ...
         (Mercado(isis,iper) + squeeze(sum(Interc(isis,:,iper))))));
   end

   fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b');
end
fprintf('   OK\n');

%---> Plota gáficos de balanço, sobras e déficit

mes = ['jan';'fev';'mar';'abr';'mai';'jun';'jul';'ago';'set';'out';'nov';'dez'];
i = 0;
clear StrMes
for iano = anoi:anoi+nanos-1
   for imes = 1:12
      i = i + 1;
      StrMes(i,:) = [mes(imes,:) '/' sprintf('%2i',iano-2000)];
   end
end

fprintf('Gerando gráficos...')
close all;
NomeSistema = {Sistema.nome};
MapaCores = [119 147  60; 
             149 179 215; 
              55  96 146; 
             255 192   0;
             85  142 213; 
             192  0    0] / 255;
         
MesInicio = 5;
MesFim = nper;
for isis = 1:9;
   figure;
   set(gcf,'Name',['Balanço - ' NomeSistema{isis}])
   b = bar([...
      GTmin(MesInicio:MesFim,isis) ...
      DispNS(isis,MesInicio:MesFim)' ...
      GHmax(MesInicio:MesFim,isis) ...
      squeeze(sum(Interc(:,isis,MesInicio:MesFim)))...
      (GTmax(MesInicio:MesFim,isis) - GTmin(MesInicio:MesFim,isis)) ...
      Deficit(isis,MesInicio:MesFim)' ],'stack');
   set(b,'edgecolor','none')
   colormap(MapaCores);
   hold on;
   MercExp = Mercado(isis,:)' + squeeze(sum(Interc(isis,:,:)));
   plot(Mercado(isis,MesInicio:MesFim),'k','LineWidth',2)
   plot(MercExp(MesInicio:MesFim,1),'k:','LineWidth',2)
   xlim([0 MesFim-MesInicio+2])
   leg = legend(...
      'Inflexibilidade',...
      'Disp. de Usinas Não Simuladas',...
      'Disponibilidade Hidroelétrica',...
      'Importação de Potência',...
      'Disponibilidade Termoelétrica',...
      'Déficit','Demanda Máxima',...
      'Demanda Máxima + Exportação de Potência',...
      'Location','Best');
   ytick = get(gca,'YTick');
   set(gca,...
      'YTickLabel',ytick,...
      'XTick',[1:2:MesFim-MesInicio+1],...
      'XTicklabel',StrMes([MesInicio:2:MesFim],:)); %,...
%      'XTickLabelRotation',90);
%   xticklabel_rotate([],90);
   ylabel('MW');
end
figure;
set(gcf,'Name','Sobras e Deficit')
colormap([1 0 0;0 1 0])
for isis = 1:4
   subplot(2,2,isis)
%   colormap([1 0 0;0 1 0])
   b = bar(-Deficit(isis,mesi:60),'r');
   hold on;
   bar(Sobra(isis,mesi:60),'g');
   xlim([0 MesFim-MesInicio+2])
   set(gca,...
         'XTick',[1:2:MesFim-MesInicio+1],...
         'XTicklabel',StrMes([MesInicio:2:MesFim],:)); %,...
%         'XTickLabelRotation',90);
%   xticklabel_rotate([],90);
   title(NomeSistema{isis})
   ylabel('MW')
end
figure;
set(gcf,'Name','Sobras e Deficit - SIN')
%colormap([1 0 0;0 1 0])
DeficitSIN = sum(Deficit);
SobraSIN = sum(Sobra);
b = bar(-DeficitSIN(mesi:60),'r');
hold on;
bar(SobraSIN(mesi:60),'g')
xlim([0 MesFim-MesInicio+2])
set(gca,...
      'XTick',[1:2:MesFim-MesInicio+1],...
      'XTicklabel',StrMes([MesInicio:2:MesFim],:)); %,...
%      'XTickLabelRotation',90);
%xticklabel_rotate([],90);
ylabel('MW')
ytick = get(gca,'YTick');
set(gca,'YTickLabel',ytick)

fprintf('   OK\n');

fprintf('FIM\n\n');
