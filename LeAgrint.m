%--------------------------------------------------------------------------
%---> Lê arquivo Agrint.dat
%--------------------------------------------------------------------------
%
% Lê os dados agrupamento de intercâmbios.
%
% Agrint(numAgrint): struct
%    nReg
%    De(nReg)
%    Para(nReg)
%    Fator(nReg)
%    Limite(60)
%

%--------------------------------------------------------------------------
%---> Lê arquivo agrint.dat
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoAgrint];
fid = fopen(NomeArquivo,'r');
for i = 1:3
    dummy = fgetl(fid);
end

numAgrint = 0;

%---> Lê os agrupamentos
card  = fgetl(fid);
iagr  = str2double(card(2:4));
while (iagr~=999) 
   isis  = str2double(card(6:8));
   jsis  = str2double(card(10:12));
   fator = str2double(card(14:20));
%---> Atribui os agrupamentos
    if iagr > numAgrint        % Cria novo registro
        numAgrint = numAgrint + 1;
        Agrint(numAgrint) = struct('nReg',0,'De',0,'Para',0,...
            'Fator',0.0,'Limite',zeros(60,1));
    end
    Agrint(iagr).nReg = Agrint(iagr).nReg + 1;
    ireg = Agrint(iagr).nReg;
    Agrint(iagr).De(ireg)   = ApontadorSistema(isis);
    Agrint(iagr).Para(ireg) = ApontadorSistema(jsis);
    Agrint(iagr).Fator(ireg) = fator;
%---> Proximo Registro
   card = fgetl(fid);
   iagr = str2double(card(2:4));
end


%---> Le os limites por grupo 
for i = 1:3
    dummy = fgetl(fid);
end
card  = fgetl(fid);
iagr  = str2double(card(2:4));
while (iagr~=999) 
    imes = str2double(card(7:8));
    iano = str2double(card(10:13));
    jmes = str2double(card(15:16));
    jano = str2double(card(18:21));
    limite = str2double(card(23:29));
    if isnan(imes)
        imes = mesi;
        iano = anoi;
    end
    if isnan(jmes)
        jmes = 12;
        jano = anoi + nanos - 1;
    end
    iper = (iano-anoi) * 12 + imes;
    jper = (jano-anoi) * 12 + jmes;
    Agrint(iagr).Limite(iper:jper) = ones(jper-iper+1,1) * limite;
%---> Proximo Registro
   card = fgetl(fid);
   iagr = str2double(card(2:4));
end

%---> Fecha o arquivo
fclose(fid);

