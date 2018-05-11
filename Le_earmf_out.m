% Le_earmf_out    Programa para ler o arquivo earmf.out gerado pelo NWLISTOP.
%
% earmf(série,período) = Le_earmf_out(arquivo,nanos,{nsim}])
%       arquivo     Nome do arquivo
%       nanos       Número de anos do arquivo
%       nsim        Número de séries (default = 2000)
%
% by Vitor Silva Duarte






teste 




function earmf = Le_earmf_out(arquivo,nanos,varargin)

%---> Defaults
nsim = 2000;

if size(varargin,2) >= 1
    nsim = varargin{1};
end

fid = fopen(arquivo);

%---> Salta o cabeçalho
for linha = 1:2
    card = fgets(fid);
end

%---> Leitura dos dados
for iano = 1:nanos

    inicio = (iano-1)*12+1;
    fim = inicio + 11;

    for linha = 1:3
        card = fgets(fid);
    end
    
    for isim = 1:nsim
        card = fgets(fid);
        if (card(10) == '-')
           earmf(isim,inicio:fim) = 0.0;
        else
           tmp = sscanf(card,'%f',[1,14]);
           earmf(isim,inicio:fim) = tmp(2:13);
        end
    end
    card = fgets(fid);  % Lê a linha de média
end

fclose(fid);

end

