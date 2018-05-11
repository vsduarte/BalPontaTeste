function DadoUsina = LeHidr(numUsi,pathHidr)

% LeHidr    Lê os registro do arquivo HIDR.DAT
%   DadoUsina = LeHidr(numUsi,pathHidr) Lê os dados da usinas hidroelétrica 
%   de código numUsi do arquivo HIDR.DAT, no caminho pathHidr e retorna 
%   a estrutura DadoUsina, contendo os registtros lidos.


%--->
LeTodoHidr = 0;
iusi = numUsi;
numeroUsinas = 1;
if (numUsi == -1)
    numeroUsinas = 320;
    LeTodoHidr = 1;
end

%---> Abre o arquivo HIDR.DAT
NomeArquivoHidr = [pathHidr '/HIDR.DAT'];
fid = fopen(NomeArquivoHidr,'r','n');

%---> Posiciona o ponteiro no inicio da usina
if LeTodoHidr == 0
    skip = (numUsi-1) * 792;
    Dummy = fread(fid,skip,'bit8');
end

%---> Le dados das usinas
for iusi = 1:numeroUsinas
    DadoUsina(iusi).Numero        = iusi;
    DadoUsina(iusi).Nome          = char(fread(fid,12,'char*1')');
    DadoUsina(iusi).Posto         = fread(fid,1,'int');
    DadoUsina(iusi).PostoBDH      = char(fread(fid,8,'char*1')');
    DadoUsina(iusi).Sistema       = fread(fid,1,'int');
    DadoUsina(iusi).Empresa       = fread(fid,1,'int');
    DadoUsina(iusi).Jusante       = fread(fid,1,'int');
    DadoUsina(iusi).Desvio        = fread(fid,1,'int');
    DadoUsina(iusi).VolMin        = fread(fid,1,'single');
    DadoUsina(iusi).VolMax        = fread(fid,1,'single');
    DadoUsina(iusi).VolVertedouro = fread(fid,1,'single');
    DadoUsina(iusi).VolDesvio     = fread(fid,1,'single');
    DadoUsina(iusi).CotaMin       = fread(fid,1,'single');
    DadoUsina(iusi).CotaMax       = fread(fid,1,'single');
    for i = 1:5
        DadoUsina(iusi).PCV(i) = fread(fid,1,'single');
    end
    for i = 1:5
        DadoUsina(iusi).PCA(i) = fread(fid,1,'single');
    end
    for i = 1:12
        DadoUsina(iusi).Evapora(i) = fread(fid,1,'int');
    end
    DadoUsina(iusi).NumCnjMaq = fread(fid,1,'int');
    for i = 1:5
        DadoUsina(iusi).NumMaq(i) = fread(fid,1,'int');
    end
    for i = 1:5
        DadoUsina(iusi).Potef(i) = fread(fid,1,'single');
    end
    for i = 1:5
        for j = 1:5
            DadoUsina(iusi).QHT(i,j) = fread(fid,1,'single');
        end
    end
    for i = 1:5
        for j = 1:5
            DadoUsina(iusi).QHG(i,j) = fread(fid,1,'single');
        end
    end
    for i = 1:5
        for j = 1:5
            DadoUsina(iusi).PH(i,j) = fread(fid,1,'single');
        end
    end
    for i = 1:5
        DadoUsina(iusi).HEf(i) = fread(fid,1,'single');
    end
    for i = 1:5
        DadoUsina(iusi).QEf(i) = fread(fid,1,'int');
    end
    DadoUsina(iusi).Prodt         = fread(fid,1,'single');
    DadoUsina(iusi).Perdas        = fread(fid,1,'single');
    DadoUsina(iusi).NumPolJus     = fread(fid,1,'int');
    for pol = 1:5
        for i = 1:5
            DadoUsina(iusi).PolJus(pol,i) = fread(fid,1,'single');
        end
    end
    for i = 1:5
        DadoUsina(iusi).Dummy        = fread(fid,1,'single');
    end
    for i = 1:5
        DadoUsina(iusi).PolJusRef(i) = fread(fid,1,'single');
    end
    DadoUsina(iusi).Dummy1     = fread(fid,1,'int');
    DadoUsina(iusi).CanalFuga  = fread(fid,1,'single');
    DadoUsina(iusi).InfVertCF  = fread(fid,1,'int');
    DadoUsina(iusi).FCMax      = fread(fid,1,'single');
    DadoUsina(iusi).FCMin      = fread(fid,1,'single');
    DadoUsina(iusi).VazMin     = fread(fid,1,'int');
    DadoUsina(iusi).NumBase    = fread(fid,1,'int');
    DadoUsina(iusi).TipoTurb   = fread(fid,1,'int');
    DadoUsina(iusi).RepConj    = fread(fid,1,'int');
    DadoUsina(iusi).TEIF       = fread(fid,1,'single');
    DadoUsina(iusi).IP         = fread(fid,1,'single');
    DadoUsina(iusi).TipoPerdas = fread(fid,1,'int');
    DadoUsina(iusi).Data       = char(fread(fid,8,'char*1')');
    DadoUsina(iusi).Obs        = char(fread(fid,43,'char*1')');
    DadoUsina(iusi).VolRef     = fread(fid,1,'single');
    DadoUsina(iusi).Regulariza = char(fread(fid,1,'char*1')');
end
%---> Fecha o arquivo HIDR.DAT
fclose(fid);

end