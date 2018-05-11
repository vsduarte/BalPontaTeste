%--------------------------------------------------------------------------
%---> Lê arquivo confhd
%--------------------------------------------------------------------------
%
% Lê os dados cadastrais e de expansão das usinas hidroelétricas que fazem 
% parte de um deck e armazena nas seguintes estruturas:
%
% ConfHd = 1xNumUsinas
%     numero
%     nome
%     subsistema
%     status
%     modif
%     NumConj
%     NumMaq
%     CFuga
%
% DadoCadastroUsina = 1xNumUsinas
%     Nome
%     Posto
%     PostoBDH
%     Sistema
%     Empresa
%     Jusante
%     Desvio
%     VolMin
%     VolMax
%     VolVertedouro
%     VolDesvio
%     CotaMin
%     CotaMax
%     PCV
%     PCA
%     Evapora
%     NumCnjMaq
%     NumMaq
%     Potef
%     QHT
%     QHG
%     PH
%     HEf
%     QEf
%     Prodt
%     Perdas
%     NumPolJus
%     PolJus
%     Dummy
%     PolJusRef
%     Dummy1
%     CanalFuga
%     InfVertCF
%     FCMax
%     FCMin
%     VazMin
%     NumBase
%     TipoTurb
%     RepConj
%     TEIF
%     IP
%     TipoPerdas
%     Data
%     Obs
%     VolRef
%     Regulariza
    
%--------------------------------------------------------------------------
%---> Lê arquivo Confhd
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoConfHd];
fid_confhd = fopen(NomeArquivo,'r');
dummy = fgetl(fid_confhd);
dummy = fgetl(fid_confhd);
ConfHd = struct();
ApontadorConfHd = zeros(320,1);
nusi = 0;
while ~feof(fid_confhd)
    card = fgetl(fid_confhd);
    stat = strtrim(card(43:46));
    if(~strcmp(stat,'NC') & ~strcmp(stat,'nc'))
        nusi = nusi + 1;
        ConfHd(nusi).numero  = str2num(card(2:5));
        ConfHd(nusi).nome    = strtrim(card(7:18));
        ConfHd(nusi).subsistema = str2num(card(31:34));
        ConfHd(nusi).status  = strtrim(card(43:46));
        ConfHd(nusi).modif   = str2num(card(50:53));
        ApontadorConfHd(ConfHd(nusi).numero) = nusi;
    end
end
fclose(fid_confhd);

%--------------------------------------------------------------------------
%---> Lê arquivo Hidr
%--------------------------------------------------------------------------
Hidr = LeHidr(-1,path);
for iusi = 1:size(ConfHd,2)
     DadoCadastroUsina(iusi) = Hidr(ConfHd(iusi).numero);
%---> Inicializa maquinas e número de conjunto de maquinas da usina iusi
%     com o dado de cadastro para as usinas existentes e com zero para as
%     EE e NE.
     ConfHd(iusi).NumConj = DadoCadastroUsina(iusi).NumCnjMaq;
     flagStatus = 1;
     if strcmp(ConfHd(iusi).status,'EX') ~= 1 
         flagStatus = 0;
     end
     for iper = 1:nper
         for imaq = 1:5
             ConfHd(iusi).NumMaq(imaq,iper) = ...
                 DadoCadastroUsina(iusi).NumMaq(imaq) * flagStatus;
         end
         ConfHd(iusi).CFuga(iper) = DadoCadastroUsina(iusi).CanalFuga;
     end
end
clear Hidr;

%--------------------------------------------------------------------------
%---> Lê arquivo de modificações cadastrais
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoModif];
fid_modif = fopen(NomeArquivo,'r');
dummy = fgetl(fid_modif);
dummy = fgetl(fid_modif);
while ~feof(fid_modif)
    card = fgetl(fid_modif);
    if (strcmp(strtrim(card(2:9)),'USINA'))         % Usina a ser alterada
      usina = str2num(card(11:31));
      iusi = ApontadorConfHd(usina);
    end
    if (strcmp(strtrim(card(2:9)),'CFUGA'))         % Canal de Fuga
       dado = sscanf(card(11:size(card,2)),'%i %i %f');
       mes = dado(1); ano = dado(2); cfuga = dado(3);
       peri = (ano-anoi)*12 + mes;
       if(iusi~=0) 
          for iper = peri:nper
             ConfHd(iusi).CFuga(iper) = cfuga;
          end
       end
    end
    if (strcmp(strtrim(card(2:9)),'NUMMAQ'))         % Número de Máquinas
       dado = sscanf(card(11:size(card,2)),'%i %i');
       numconj = dado(2); nummaq = dado(1);
       peri = mesi;
       if(iusi~=0)
          for iper = peri:nper
             ConfHd(iusi).NumMaq(numconj,iper) = nummaq;
          end
       end
    end
end
fclose(fid_modif);

%--------------------------------------------------------------------------
%---> Lê arquivo de expansão
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoExph];
fid_exph = fopen(NomeArquivo,'r');
dummy = fgetl(fid_exph);
dummy = fgetl(fid_exph);
dummy = fgetl(fid_exph);
while ~feof(fid_exph)
   card = fgetl(fid_exph);
   iusi = str2num(card(1:4));
   while(~strcmp(card(1:4),'9999') | strcmp(card(1:4),'    '))
      if(size(card,2) >= 65)           % É um registro de máquina
         mes = str2num(card(45:46));
         ano = str2num(card(48:51));         
         conjunto = str2num(card(64:65));
         jper = (ano-anoi) * 12 + mes;
         if(ApontadorConfHd(iusi)~=0)
             for iper = jper:nper
                 ConfHd(ApontadorConfHd(iusi)).NumMaq(conjunto,iper) = ...
                     ConfHd(ApontadorConfHd(iusi)).NumMaq(conjunto,iper) + 1;
             end
         end
      end
      card = fgetl(fid_exph);
   end   
end
fclose(fid_exph);
