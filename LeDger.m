%--------------------------------------------------------------------------
%---> L� arquivo dger
%--------------------------------------------------------------------------
%
% L� os dados 
NomeArquivo = [path '/' NomeArquivoDger];
fid_dger = fopen(NomeArquivo,'r');
dummy = fgetl(fid_dger);
dummy = fgetl(fid_dger);
dummy = fgetl(fid_dger);
card = fgetl(fid_dger); nanos = str2num(card(25));              % N�mero de anos de estudo
dummy = fgetl(fid_dger);
card = fgetl(fid_dger); mesi = str2num(card(24:25));            % M�s inicial
card = fgetl(fid_dger); anoi = str2num(card(22:25));            % Ano inicial
card = fgetl(fid_dger); nanosPre = str2num(card(22:25));        % Numero anos pre
card = fgetl(fid_dger); nanosPos = str2num(card(22:25));        % Numero anos pos
for i = 1:23                           % Salta 25 linhas
    dummy = fgetl(fid_dger);
end
card = fgetl(fid_dger); nAnosManut = str2num(card(22:25));      % Numero de anos de manut


fclose(fid_dger);

nper = nanos * 12;               % N�mero de meses do estudo