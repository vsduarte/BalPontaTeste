%
%   Programa Balanço de Ponta
%

%---> Inicia contador de tempo
tic

%=== INICIALIZAÇÃO ========================================================
clear all; clc
%path = './P05_2016';
path = './Sensibilidade_Caso3';
ERR = 1;
%path = uigetdir;

%=== ESCOLHA DO TIPO DE SIMULAÇÃO =========================================
%
%   =1  Determinístico
%   =2  Estocástico
%
%=== ESCOLHA DO TIPO DE PERDAS ============================================
%
%   =1  Funcao de Perdas
%   =2  Perdas pela operação em paralelo
%   =3  Pdisp Lido do Suishi
%
TipoSimulacao = 2;
TipoPerdas = 3;
reserva = 2.5;

if (TipoSimulacao==1)
   nsim = 1;
   if (TipoPerdas==3)
      TipoPerdas=1;
   end
end
%=== LEITURA DE DADOS =====================================================

%--------------------------------------------------------------------------
%---> Lê arquivo caso.dat
%--------------------------------------------------------------------------
NomeArquivoCaso = [path '/caso.dat'];
fid_caso = fopen(NomeArquivoCaso,'r');
NomeArquivoArquivos = fscanf(fid_caso,'%s');
fclose(fid_caso);

%--------------------------------------------------------------------------
%---> Lê arquivo arquivos.dat
%--------------------------------------------------------------------------
NomeArquivoArquivos = [path '/' NomeArquivoArquivos];
fid_arquivos = fopen(NomeArquivoArquivos,'r');
card = fgetl(fid_arquivos);NomeArquivoDger = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos);NomeArquivoSistema = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos); NomeArquivoConfHd = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos); NomeArquivoModif = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos); NomeArquivoConfT = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos); NomeArquivoTerm = ...
   strtrim(card(30:size(card,2)));
dummy = fgetl(fid_arquivos);
card = fgetl(fid_arquivos); NomeArquivoExph = ...
   strtrim(card(30:size(card,2)));
card = fgetl(fid_arquivos); NomeArquivoExpt = ...
   strtrim(card(30:size(card,2)));
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
card = fgetl(fid_arquivos); NomeArquivoManutT = ...
   strtrim(card(30:size(card,2)));
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
card = fgetl(fid_arquivos); NomeArquivoCAdic = ...
   strtrim(card(30:size(card,2)));
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
dummy = fgetl(fid_arquivos);
card = fgetl(fid_arquivos); NomeArquivoAgrint = ...
   strtrim(card(30:size(card,2)));
fclose(fid_arquivos);

%--------------------------------------------------------------------------
%---> Lê Dados Gerais
%--------------------------------------------------------------------------
fprintf('Lendo dados gerais...')
LeDger;
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Lê Configuração Hidroelétrica
%--------------------------------------------------------------------------
fprintf('Lendo configuração hidroelétrica...')
LeConfigHidro;
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Lê Configuração Termoelétrica
%--------------------------------------------------------------------------
fprintf('Lendo configuração termoelétrica...')
LeConfigTermo;
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Lê Subsistemas (Mercado, Intercambios e Não Simuladas)
%--------------------------------------------------------------------------
fprintf('Lendo dados de mercado, limites de intercâmbios e não simuladas...')
LeSistema;
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Lê Agrupamentos de Intercambios
%--------------------------------------------------------------------------
fprintf('Lendo dados de agrupamentos de intercâmbios...')
LeAgrint;
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Lê Série de Armazenamentos (Deterministico)
%--------------------------------------------------------------------------
if (TipoSimulacao == 1)
   fprintf('Lendo série de energia armazenada...')
   NomeArquivoEAR = [path '/Armazenamento.csv'];
   EAR = zeros(nper,nsis);
   dummy = dlmread(NomeArquivoEAR,';',2,1);
   EAR(1:size(dummy,1),1:size(dummy,2)) = dummy;
   fprintf('   OK\n');
end

%--------------------------------------------------------------------------
%---> Lê Arquivo com as séries de armazenamentos (Probabilistico)
%--------------------------------------------------------------------------
if (TipoSimulacao == 2 && TipoPerdas ~= 3)
   fprintf('Lendo arquivo de armazenamentos...')
   clear EAR_newave
   for isis = 1:nsis
      arquivo_EAR = [path '/earmfp' sprintf('%2.2i',isis') '.out'];
      if (exist(arquivo_EAR,'file') ~= 2)
         fprintf('\n\nERRO: O arquivo %s não existe\n',arquivo_EAR);
         ERR = 1;
         return
      end
      EAR_tmp = Le_earmf_out(arquivo_EAR,5);
      EAR(:,isis,:) = EAR_tmp';
   end
   nsim = size(EAR,3);
   fprintf('   OK\n');
end

%--------------------------------------------------------------------------
%---> Lê Arquivo com as Potências Disponíveis (uso do PDISP do SUISHI)
%--------------------------------------------------------------------------
if (TipoPerdas == 3)
   LePdisp;
   if (ERR==1)
      return
   end
end
%--------------------------------------------------------------------------
%---> Lê Injeção de Potência Adicional
%--------------------------------------------------------------------------
OfertaAdicional = zeros(nper,nsis);
NomeArquivoOferta = [path '/OfertaAdicional.csv'];
if (exist(NomeArquivoOferta,'file') == 2)
   fprintf('Lendo injeção de potência adicional...')
   dummy = dlmread(NomeArquivoOferta,';',1,1);
   vsis = dummy(1,:);
   dummy(1,:) = [];
   for isis = 1:size(vsis,2)
      jsis = ApontadorSistema(vsis(isis));
      OfertaAdicional(:,jsis) = OfertaAdicional(:,jsis) + dummy(:,isis);
   end
   fprintf('   OK\n');
end

%--------------------------------------------------------------------------
%---> Lê Arquivo de Perdas Fixas
%--------------------------------------------------------------------------
fprintf('Lendo arquivo de perdas fixas...')
LePerdaFixa;
fprintf('   OK\n');

fprintf('FIM DA LEITURA DE DADOS\n\n')

%=== CÁLCULO DE VARIÁVEIS DO SIST. EQUIVALENTE =============================

%--------------------------------------------------------------------------
%---> Calcula Perdas por Delecinamento, por Subsisetma
%--------------------------------------------------------------------------
if (TipoPerdas == 1)
   fprintf('Calculando perdas por delecionamento...')
   NomeArquivoPerdas = [path '/FuncaoPerdas.csv'];
   FuncPerdasEAR = dlmread(NomeArquivoPerdas,';',2,1);
   if (TipoSimulacao == 1)
      PerdaDeplecinamento = CalcPerdas_poly(nsis,FuncPerdasEAR,EAR);
   else
      for isim = 1:nsim
         PerdaDeplecinamento(:,:,isim) = ...
            CalcPerdas_poly(nsis,FuncPerdasEAR,squeeze(EAR(:,:,isim)));
      end
   end
   fprintf('   OK\n');
end

%--------------------------------------------------------------------------
%---> Calcula Potência Instalada das hidrúlicas
%--------------------------------------------------------------------------
fprintf('Calculando potência instalada hidroelétrica...')
CalcPinstH;
for isim = 1:nsim
   GHmax(:,:,isim) = GHmax(:,:,isim) + OfertaAdicional;
end
fprintf('   OK\n');

%--------------------------------------------------------------------------
%---> Calcula Potência Instalada das termoelétricas
%--------------------------------------------------------------------------
fprintf('Calculando potência instalada termoelétrica...')
CalcPinstT;
fprintf('   OK\n');

fprintf('FIM DO CÁLCULO DE VARIÁVEIS DO SIST. EQUIVALENTE\n\n')


%=== SOLUÇÃO DO BALANÇO DE PONTA ==========================================

%---> Prepara dados para a solução do Balanço
LimInterc = zeros((nsis+nfic)*(nsis+nfic)-(nsis+nfic),iper);
for iper = mesi:nper
   Matriz = zeros(1,60); Matriz(iper) = 1;
   DispNS(:,iper) = Matriz * [Sistema.NaoSimul];
   Mercado(:,iper) = Matriz * [Sistema.Mercado];        % *(1+reserva/100);
   ivar = 0;
   for isis = 1:nsis+nfic
      for jsis = 1:isis-1
         ivar = ivar + 1;
         iApontador = ApontadorIntercambio(isis,jsis);
         if (iApontador ~= 0)
            LimInterc(ivar,iper) = Intercambio(iApontador).capacidade(iper);
         end
      end
      for jsis = isis+1:nsis+nfic
         ivar = ivar + 1;
         iApontador = ApontadorIntercambio(isis,jsis);
         if (iApontador ~= 0)
            LimInterc(ivar,iper) = Intercambio(iApontador).capacidade(iper);
         end
      end
   end
end
toc
if (TipoSimulacao == 1)
   %---> Balanço de ponta determinístico
   BalancoPontaDeterministico;
end
if (TipoSimulacao == 2)
   %---> Balanço de ponta determinístico
   BalancoPontaProbabilistico;
end

%---> Fim do contador de tempo
Tempo = toc
