NomeArquivoEAR = 'arquivos_EAR.dat';
sNomeArquivo = [path '/' NomeArquivoEAR];
%fid_ear = fopen(NomeArquivo,'r');
dummy = dlmread(NomeArquivo,' ');

%fclose(fid_ear);