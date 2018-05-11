%--------------------------------------------------------------------------
%---> Lê arquivo de perdas fixas
%--------------------------------------------------------------------------
%
perdaFixa = ones(nper,nsis)*(-1);
NomeArquivo = [path '/PerdaFixa.dat'];
fid_perdaFixa = fopen(NomeArquivo,'r');
if(fid_perdaFixa == -1)
   return
end
dummy = fgetl(fid_perdaFixa);
dummy = fgetl(fid_perdaFixa);
dummy = fgetl(fid_perdaFixa);
card = fgetl(fid_perdaFixa); 
while ~feof(fid_perdaFixa)
   isis       = str2num(card(1:3));
   isis = ApontadorSistema(isis);
   mes_inicio = str2num(card(7:8));
   ano_inicio = str2num(card(10:13));
   mes_fim    = str2num(card(15:16));
   ano_fim    = str2num(card(18:21));
   valor      = str2double(card(23:size(card,2)));
   iniper = (ano_inicio - anoi)*12 + mes_inicio;
   fimper = (ano_fim - anoi)*12 + mes_fim;
   for iper = iniper:fimper
      perdaFixa(iper,isis) = valor;
   end
   card = fgetl(fid_perdaFixa); 
end
fclose(fid_perdaFixa);
