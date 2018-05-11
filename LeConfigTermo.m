%--------------------------------------------------------------------------
%---> Lê arquivo conft
%--------------------------------------------------------------------------
%
% Lê os dados cadastrais e de expansão das usinas termoeletricas que fazem 
% parte de um deck e armazena nas seguintes estruturas:
%
% ConfT = 1xNumUsinas
%     numero
%     nome
%     subsistema
%     status
%     Potef
%     FcMax
%     Teif
%     Teip
%     GtMin

%--------------------------------------------------------------------------
%---> Lê arquivo Conft
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoConfT];
fid_conft = fopen(NomeArquivo,'r');
dummy = fgetl(fid_conft);
dummy = fgetl(fid_conft);
ConfT = struct();
ApontadorConfT = zeros(320,1);
nusiTerm = 0;

while ~feof(fid_conft)
    card = fgetl(fid_conft);
    stat = strtrim(card(31:32));
    if(~strcmpi(stat,'NC'))
        nusiTerm = nusiTerm + 1;
        ConfT(nusiTerm).numero     = str2double(card(2:5));
        ConfT(nusiTerm).nome       = strtrim(card(7:18));
        ConfT(nusiTerm).subsistema = str2double(card(22:25));
        ConfT(nusiTerm).status     = strtrim(card(31:32));
        ConfT(nusiTerm).Potef = zeros(nper,1);
        ConfT(nusiTerm).FcMax = zeros(nper,1);
        ConfT(nusiTerm).Teif  = zeros(nper,1);
        ConfT(nusiTerm).Teip  = zeros(nper,1);
        ConfT(nusiTerm).GtMin = zeros(nper,1);

        ApontadorConfT(ConfT(nusiTerm).numero) = nusiTerm;
    end
end
fclose(fid_conft);

%--------------------------------------------------------------------------
%---> Lê arquivo Term
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoTerm];
fid = fopen(NomeArquivo,'r');
dummy = fgetl(fid);
dummy = fgetl(fid);
while ~feof(fid)
    card = fgetl(fid);
    iusi = ApontadorConfT(str2double(card(2:4)));
    if(iusi~=0)
        fator = 0;
        if(strcmpi(ConfT(iusi).status,'EX'))
            fator = 1;
        end
        for iper = mesi:nper
            ConfT(iusi).Potef(iper) = str2double(card(20:24)) * fator;
            ConfT(iusi).FcMax(iper) = str2double(card(26:29))/100;
            ConfT(iusi).Teif(iper)  = str2double(card(32:37))/100;
            ConfT(iusi).Teip(iper)  = str2double(card(39:44))/100;
            ConfT(iusi).GtMin(iper) = str2double(card(130:135)) * fator;
        end
        ini = 46;
        for iper = 1:nAnosManut*12      % Zera o IPTER das UTEs nos anos de manut
            ConfT(iusi).Teip(iper) = 0;
        end
        for iper = 1:12    % GtMin do primeiro ano
            fim = ini + 5;
            ConfT(iusi).GtMin(iper) = str2double(card(ini:fim)) * fator;
            ini = fim + 2;
        end
    end
end
fclose(fid);

%--------------------------------------------------------------------------
%---> Lê arquivo Expt
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoExpt];
fid = fopen(NomeArquivo,'r');
dummy = fgetl(fid);
dummy = fgetl(fid);
while ~feof(fid)
    card  = [fgetl(fid) '                  '];
    num   = str2double(card(1:4));
    key   = strtrim(card(6:10));
    valor = str2double(card(12:19));
    mesinicio  = str2double(card(21:22));
    anoinicio  = str2double(card(24:27));
    mesfim     = str2double(card(29:30));
    anofim     = str2double(card(32:35));
    iniper = (anoinicio-anoi)*12 + mesinicio;
    fimper = (anofim-anoi)*12 + mesfim;
    if (isnan(iniper))
        iniper = mesi;
    end
    if (isnan(fimper))
        fimper = nper;
    end
    if (strcmpi(key,'POTEF'))           % Atribui Potef
        for iper = iniper:fimper
            ConfT(ApontadorConfT(num)).Potef(iper) = valor;
        end
    end
    if (strcmpi(key,'FCMAX'))           % Atribui FcMax
        for iper = iniper:fimper
            ConfT(ApontadorConfT(num)).FcMax(iper) = valor/100;
        end
    end
    if (strcmpi(key,'TEIFT'))           % Atribui Teif
        for iper = iniper:fimper
            ConfT(ApontadorConfT(num)).Teif(iper) = valor/100;
        end
    end
    if (strcmpi(key,'IPTER'))           % Atribui Teip
        for iper = iniper:fimper
            ConfT(ApontadorConfT(num)).Teip(iper) = valor/100;
        end
    end
    if (strcmpi(key,'GTMIN'))           % Atribui GtMin
        for iper = iniper:fimper
            ConfT(ApontadorConfT(num)).GtMin(iper) = valor;
        end
    end
end
fclose(fid);

%--------------------------------------------------------------------------
%---> Lê arquivo Manutt
%--------------------------------------------------------------------------
NumDiasMes = [31 28 31 30 31 30 31 31 30 31 30 31];
NomeArquivo = [path '/' NomeArquivoManutT];
fid = fopen(NomeArquivo,'r');
dummy = fgetl(fid);
dummy = fgetl(fid);
while ~feof(fid)
    card = fgetl(fid);
    iusi = ApontadorConfT(str2double(card(18:20)));
    if(iusi~=0)
        DiaInicioManut = str2double(card(41:42));
        MesInicioManut = str2double(card(43:44));
        AnoInicioManut = str2double(card(45:48));
        NumDiasManut   = str2double(card(50:52));
        PotEmManut     = str2double(card(56:62));
        while(NumDiasManut > 0 & nAnosManut > 0 )
            DiasManutMes = min(NumDiasManut,...
                (NumDiasMes(MesInicioManut)-DiaInicioManut+1));
            % Calculo de TEIP
            iper = (AnoInicioManut-anoi)*12 + MesInicioManut;
            if (ConfT(iusi).Teip(iper)==0)
                ConfT(iusi).Teip(iper) = ...
                    PotEmManut / ConfT(iusi).Potef(iper) * ...
                    NumDiasManut / NumDiasMes(MesInicioManut);
            else
                ConfT(iusi).Teip(iper) = ConfT(iusi).Teip(iper) * ...
                    PotEmManut / ConfT(iusi).Potef(iper) * ...
                    NumDiasManut / NumDiasMes(MesInicioManut);
            end                
            % Atualiza dias de manutenção para o proximo mês
            DiaInicioManut = 1;
            MesInicioManut = MesInicioManut + 1;
            if (MesInicioManut == 13)
                MesInicioManut = 1;
                AnoInicioManut = AnoInicioManut + 1;
            end
            NumDiasManut = NumDiasManut - DiasManutMes;
        end
    end
end
fclose(fid);

