%--------------------------------------------------------------------------
%---> Lê arquivo sistema.dat
%--------------------------------------------------------------------------
%
% Lê os dados de mercado, limites de intercâmbios e usinas não simuladas.
%
% Os dados dos subsistemas estão armazenados na seguinte estrutura:
%
% Sistema = 1xNumSistemas
%     numero
%     nome
%     tipo
%     Mercado
%     NaoSimul
%
% Os dados dos intercâmbios estão armazenados na seguinte estrutura:
%
% Intercâmbio = 1xNumLinhas
%     origem
%     destino
%     capacidade
%

Sistema = struct();
Intercambio = struct();
%--------------------------------------------------------------------------
%---> Lê arquivo sistema.dat
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoSistema];
fid = fopen(NomeArquivo,'r');
for i = 1:7
    dummy = fgetl(fid);
end
%---> Lê os subsistemas
card = fgetl(fid);
isis = str2double(card(2:4));
nsis = 0;
nfic = 0;
jsis = 0;
while (isis~=999) 
   if (str2num(card(18:18)) == 0)
      nsis = nsis + 1;
   else
      nfic = nfic + 1;
   end
   jsis = jsis + 1;
   Sistema(jsis).numero = isis;
   Sistema(jsis).nome = strtrim(card(6:15));
   Sistema(jsis).tipo = str2num(card(18:18));
   Sistema(jsis).Mercado = zeros(nper,1);
   Sistema(jsis).NaoSimul = zeros(nper,1);
   ApontadorSistema(isis,1) = jsis;
   card = fgetl(fid);
   isis = str2double(card(2:4));
end
for i = 1:3
    dummy = fgetl(fid);
end

%---> Lê os intercâmbios
card = [fgetl(fid) '      '];
isis = str2double(card(2:4));
nlinha = 0;
while (isis~=999) 
    isis = ApontadorSistema(isis);
    jsis = ApontadorSistema(str2double(card(6:8)));
%   Sentido isis -> jsis
    nlinha = nlinha + 1;
    Intercambio(nlinha).origem = isis;
    Intercambio(nlinha).destino = jsis;
    ApontadorIntercambio(isis,jsis) = nlinha;
    inicio = 1;
    fim = inicio + 11;
    for iano = 1:nanos
        card = [fgetl(fid) '      '];
        tmp = sscanf(card(8:102),'%7f');
        Intercambio(nlinha).capacidade(inicio:fim,1) = [zeros(12-size(tmp,1),1); tmp];
        inicio = fim + 1;
        fim = inicio + 11;
    end
    card = [fgetl(fid) '            '];
%   Sentido jsis -> isis
    nlinha = nlinha + 1;
    Intercambio(nlinha).origem = jsis;
    Intercambio(nlinha).destino = isis;
    ApontadorIntercambio(jsis,isis) = nlinha;
    inicio = 1;
    fim = inicio + 11;
    for iano = 1:nanos
        card = [fgetl(fid) '      '];
        tmp = sscanf(card(8:102),'%7f');
        Intercambio(nlinha).capacidade(inicio:fim,1) = [zeros(12-size(tmp,1),1); tmp];
        inicio = fim + 1;
        fim = inicio + 11;
    end
    card = [fgetl(fid) '            '];
    isis = str2double(card(2:4));
end
for i = 1:3
    dummy = fgetl(fid);
end
%---> Lê os mercados médios anuais
card = [fgetl(fid) '      '];
isis = str2double(card(2:4));
while (isis~=999)
    isis = ApontadorSistema(isis);
    inicio = 1;
    fim = inicio + 11;
    if (nanosPre > 0)
        dummy = fgetl(fid);
    end        
    for iano = 1:nanos
        card = [fgetl(fid) '      '];
        tmp = sscanf(card(8:102),'%7f');
        Sistema(isis).Mercado(inicio:fim,1) = ...
           [zeros(12-size(tmp,1),1); tmp] * (1+reserva/100);
        inicio = fim + 1;
        fim = inicio + 11;
    end
    if (nanosPos > 0)
        dummy = fgetl(fid);
    end        
    card = [fgetl(fid) '      '];
    isis = str2double(card(2:4));
end
for i = 1:3
    dummy = fgetl(fid);
end
%---> Lê os dados de usinas não simuladas
card = [fgetl(fid) '      '];
isis = str2double(card(2:4));
while (isis~=999) 
    isis = ApontadorSistema(isis);
    inicio = 1;
    fim = inicio + 11;
    for iano = 1:nanos
        card = [fgetl(fid) '      '];
        tmp = sscanf(card(8:102),'%7f');
        Sistema(isis).NaoSimul(inicio:fim,1) = ...
           Sistema(isis).NaoSimul(inicio:fim,1) + ...
           [zeros(12-size(tmp,1),1); tmp];
        inicio = fim + 1;
        fim = inicio + 11;
    end
    card = [fgetl(fid) '      '];
    isis = str2double(card(2:4));
end
fclose(fid);
%--------------------------------------------------------------------------
%---> Lê arquivo C_Adic.dat
%--------------------------------------------------------------------------
NomeArquivo = [path '/' NomeArquivoCAdic];
fid = fopen(NomeArquivo,'r');
for i = 1:2
    dummy = fgetl(fid);
end
%---> Lê Cargas Adicionais
card = [fgetl(fid) '      '];
isis = str2double(card(2:4));
while (isis~=999)
    isis = ApontadorSistema(isis);
    inicio = 1;
    fim = inicio + 11;
    if (nanosPre > 0)
        dummy = fgetl(fid);
    end        
    for iano = 1:nanos
        card = [fgetl(fid) '      '];
        tmp = sscanf(card(8:102),'%7f');
        Sistema(isis).Mercado(inicio:fim,1) = ...
            Sistema(isis).Mercado(inicio:fim,1) + ...
            [zeros(12-size(tmp,1),1); tmp];
        inicio = fim + 1;
        fim = inicio + 11;
    end
    if (nanosPos > 0)
        dummy = fgetl(fid);
    end        
    card = [fgetl(fid) '      '];
    isis = str2double(card(2:4));
end
