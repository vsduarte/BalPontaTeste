% Lê e organiza os dados de potencia disponível do suishi em matrizes
%
% Os arquivos USIHIDxxx.CSV gerados pelo SUISHI devem ser colocados em uma
% pasta Pdisp, nocalizada na pasta onde estão os dados do caso.
% A configuração (topologia) será definida pelo arquivo confdh, do NEWAVE,
% independente de como o Suishi foi executado.

%---> Inicialização de variáveis
npmc = 3;            % 3 patamares de marcado
pathPdisp = [path '/Pdisp/'];
NArquivo = ['USIHID_' sprintf('%3.3i',ConfHd(1).numero) '.CSV'];
if (exist([pathPdisp NArquivo],'file') ~= 2)
   fprintf('\nERRO: O arquivo %s não existe\n',[pathPdisp NArquivo]);
   ERR = 1;
   return
end
dados = dlmread([pathPdisp NArquivo],',');
nsim = size(dados,1)/(nper-mesi+1)/npmc;
pdisp = zeros(nusi,nper,nsim,npmc);
pdisp_rev = pdisp;
pdisp_sist = zeros(nper,nsis,nsim);
pdisp_sist_rev = zeros(nper,nsis,nsim);

fprintf('Lendo arquivo de potência disponível\n')
fprintf('%s',blanks(52))
for iusi = 1:nusi
   NArquivo = ['USIHID_' sprintf('%3.3i',ConfHd(iusi).numero) '.CSV'];
   if (exist([pathPdisp NArquivo],'file') ~= 2)
      fprintf('\nERRO: O arquivo %s não existe\n',[pathPdisp NArquivo]);
      ERR = 1;
      return
   end
   dados = dlmread([pathPdisp NArquivo],',');
   for ireg = 1:size(dados,1);
      imes = dados(ireg,3);                              % mes
      iano = dados(ireg,2);                              % ano
      iper = (iano-anoi)*12 + imes;                      % periodo
      isim = dados(ireg,4)-1931+1;                       % serie historica
      ipat = dados(ireg,5);                              % patamar
      pdisp(iusi,iper,isim,ipat) = dados(ireg,16);       % Pot. disponível
      pdisp_rev(iusi,iper,isim,ipat) = dados(ireg,26);   % Pot. disponível revisada
      isis = ApontadorSistema(ConfHd(iusi).subsistema);  % Subsistema
      if ipat == 1
         pdisp_sist(iper,isis,isim) = ...
            pdisp_sist(iper,isis,isim) + pdisp(iusi,iper,isim,ipat);
         pdisp_sist_rev(iper,isis,isim) = ...
            pdisp_sist_rev(iper,isis,isim) + pdisp_rev(iusi,iper,isim,ipat);
      end
   end
%---> Barra de acompanhamento
   iusi_percentual = round((iusi/nusi)*100/2);
   for i = 1:52;fprintf('\b');end
   fprintf('[')
   for i = 1:iusi_percentual
     fprintf('%c','#')
   end
   fprintf(blanks(50-iusi_percentual))
   fprintf(']')
end
fprintf('\n')

