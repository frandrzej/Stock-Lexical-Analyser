% parse_document(...) will take a html file (intput) argument
% and following 10 (output) arguments:
% pelna nazwa emitenta
% skrocona nazwa emitenta
% sektor
% NIP
% Regon
% Data sporzadzenia
% nr komunikatu
% temat
% podstawa prawna
% tresc raportu

% temp export
:- module(html_parser, [parse_sample/12, parse_report/12]).


:- use_module(library(sgml)).
:- use_module(library(xpath)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Common
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%parse_sample
parse_sample :-
	parse_sample('sample-page.html', Symbol, FullName, ShortName, Sector, Nip, Regon, Date, ReportNumber, Title, LegalBasis, Content),
	writeln(''), writeln('** Results: **'),
	write('Symbol type (eng/non-eng): '), writeln(Symbol),
	write('Full name: '), writeln(FullName),
	write('Short name: '), writeln(ShortName),
	write('Sector: '), writeln(Sector),
	write('Nip: '), writeln(Nip),
	write('Regon: '), writeln(Regon),
	write('Date: '), writeln(Date),
	write('Report number: '), writeln(ReportNumber),
	write('Title: '), writeln(Title),
	write('Legal basis: '), writeln(LegalBasis),
	write('Content'), writeln(Content).

parse_sample(Html, Symbol, FullName, ShortName, Sector, Nip, Regon, Date, ReportNumber, Title, LegalBasis, Content) :-
	parse_report(Html, Symbol, FullName, ShortName, Sector, Nip, Regon, Date, ReportNumber, Title, LegalBasis, Content).



% parse_report(-Html, +,+,+...)
parse_report(Html, Symbol, FullName, ShortName, Sector, Nip, Regon, Date, ReportNumber, Title, LegalBasis, Content) :-

	write('Parsing '), writeln(Html),
	load_html(Html, DOM, []),

	find_summary_data_table(DOM, SummaryTable),
	symbol_report(SummaryTable, Symbol),
	full_issuer_name(SummaryTable, FullName),
	short_name(SummaryTable, ShortName),
	sector(SummaryTable, Sector),
	nip(SummaryTable, Nip),
	regon(SummaryTable, Regon),
	number_report(SummaryTable, ReportNumber),
	title(SummaryTable, Title),
	full_issuer_name(SummaryTable, FullName),

	find_report_table(DOM, MessageTableBody),
	legal_basis(MessageTableBody, LegalBasis),
	content(MessageTableBody, Content),

	find_represent_table(DOM, RepresentTable),
	date(RepresentTable, Date).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% finds data inside a cell specified by Row, Col, contained in table
% body TBody
%
% data_at_index_path(-TBody, ?Row, ?Cell, +Data)
data_at_index_path(TBody, Row, Cell, Data) :-
	xpath(TBody, //tr(Row), Tr2),
	xpath(Tr2, //td(Cell), Temp),
	Temp = element(td, _ , Data).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Report
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find_report_table(-DOM, +TableBody)
% finds table body with the stock message
find_report_table(DOM, TableDataBody) :-
	xpath(DOM, //div((@class=dane)), Div),
	xpath(Div, //table(3), Table1),
	xpath(Table1, //tbody, TBody1),
	xpath(TBody1, //tr(1), Tr1),
	xpath(Tr1, //td(1), Td1),
	xpath(Td1, //table(1), Table2),
	xpath(Table2, //tbody , TableDataBody).

content(TableBody, Data) :-
	data_at_index_path(TableBody, 12, 2, Data).

legal_basis(TableBody, Data) :-
	data_at_index_path(TableBody, 9, 2, Data).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Summary data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% find_message_table(-DOM, +Table)
% finds table body with info about PERSONS REPRESENTING THE COMPANY
find_represent_table(DOM, TableDataBody) :-
	xpath(DOM, //div((@class=dane)), Div),
	xpath(Div, //table(5), Table1),
	xpath(Table1, //tbody, TBody1),
	xpath(TBody1, //tr(1), Tr1),
	xpath(Tr1, //td(1), Td1),
	xpath(Td1, //table(1), Table2),
	xpath(Table2, //tbody , TableDataBody).


% find_summary_data_table(-DOM, +SummaryTable)
% finds table body with company data
find_summary_data_table(DOM, SummaryTable) :-
	xpath(DOM, //div((@class=dane)), Div),
	xpath(Div, //table(@class=nDokument), SummaryTable).

%%
%% summary_data_predicates(-Table, +Data)
%%

date(RepresentTable, Date) :-
	data_at_index_path(RepresentTable, 4, 2, Date).

full_issuer_name(SummaryTable, Name) :-
	data_at_index_path(SummaryTable, 4, 2, Name).

short_name(SummaryTable, Shortname) :-
	data_at_index_path(SummaryTable, 5, 2, Shortname).

title(SummaryTable, Title) :-
	data_at_index_path(SummaryTable, 6, 2, Title).

sector(SummaryTable, Sector) :-
	data_at_index_path(SummaryTable, 7, 2, Sector).

nip(SummaryTable, NIP) :-
	data_at_index_path(SummaryTable, 15, 2, NIP).

regon(SummaryTable, Regon) :-
	data_at_index_path(SummaryTable, 16, 2, Regon).

symbol_report(SummaryTable, Symbol) :-
	data_at_index_path(SummaryTable, 3, 2, Symbol).

number_report(SummaryTable, Number) :-
	data_at_index_path(SummaryTable, 19, 2, Number).

