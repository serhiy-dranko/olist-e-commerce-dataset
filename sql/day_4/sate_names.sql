CREATE TABLE state_name_translation AS 
SELECT * FROM read_csv(
'''
Abbreviation,State Name,Capital City
AC,Acre,Rio Branco
AL,Alagoas,Maceio
AP,Amapa,Macapa
AM,Amazonas,Manaus
BA,Bahia,Salvador
CE,Ceara,Fortaleza
DF,Federal District,Brasilia
ES,Espirito Santo,Vitoria
GO,Goias,Goiania
MA,Maranhao,Sao Luis
MT,Mato Grosso,Cuiaba
MS,Mato Grosso do Sul,Campo Grande
MG,Minas Gerais,Belo Horizonte
PA,Para,Belem
PB,Paraiba,Joao Pessoa
PR,Parana,Curitiba
PE,Pernambuco,Recife
PI,Piauí,Teresina
RJ,Rio de Janeiro,Rio de Janeiro
RN,Rio Grande do Norte,Natal
RS,Rio Grande do Sul,Porto Alegre
RO,Rondonia,Porto Velho
RR,Roraima,Boa Vista
SC,Santa Catarina,Florianopolis
SP,Sao Paulo,Sao Paulo
SE,Sergipe,Aracaju
TO,Tocantins,Palmas
''', 
header=True
);
