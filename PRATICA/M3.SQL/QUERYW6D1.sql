
describe factresellersales;
/* Es 1.1 Numero righe di vendita */
select 
   count(SalesOrderLineNumber) as Totale_righe_vendita
from
   factresellersales;
/* Es 1.2 importo complessivo venduto e numero totale di pezzi movimentati*/
select 
   sum(SalesAmount) as Importo_complessivo_venduto,
   sum(OrderQuantity) as Numero_totale_pezzi_movimentati
from
   factresellersales;
   /* Es 1.3 Prezzo unitario medio minimo e massimo con il valore medio arrotondato a due decimali*/
select 
   round(avg(UnitPrice),2) as Prezzo_unitario_medio,
   min(UnitPrice) as Prezzo_unitario_minimo,
   max(UnitPrice) as Prezzo_unitario_massimo
from
   factresellersales;
     /* Es 1.4 Data del primo e dell'ultimo ordine registrato*/
select 
   min(OrderDate) as primo_ordine,
   max(OrderDate) as ultimo_ordine
from
   factresellersales;
describe dimproduct;
    /* Es 2.1 quanti prodotti risultano presenti nel catalogo*/
select
  count(productkey) as numero_prodotti_totali
from dimproduct;
    /* Es 2.2 su quanti prodotti il colore risulta valorizzato*/
select
  count(color) as numero_prodotti_colore_valorizzato
from dimproduct
where color is not null;
 /* Es 2.3 colori diversi che compaiono in tabella*/
select
  count(distinct color) as numero_prodotti_colore_differenti
from dimproduct;
/* Es 2.4 elenco englishproductname e color in cui i valori non valorizzati sono sostituiti dall'etichetta non assegnato*/
select
    EnglishProductName as EnglishProductName_non_valorizzato,
    Color as Color_non_valorizzato
from dimproduct
where EnglishProductName='NA' or Color='NA';
/* Es 3.1 quanti prodotti esistono per ciascun colore in ordine di numerositá descrescente*/
select
    Color as Colore,
    count(*) as Quantita_prodotti
from dimproduct
group by Color
order by Quantita_prodotti desc;
/* Es 3.2 prezzo di listino medio minimo e massimo per ciascun colore con la media arrotondata a 2 decimali*/
select
    Color as Colore,
    round(avg(ListPrice),2) as prezzo_medio,
    min(ListPrice) as prezzo_minimo,
    max(ListPrice) as prezzo_massimo
from dimproduct
group by Color;
/* Es 3.3 query del punto 1 limitata ai soli prodotti finiti*/
select
    Color as Colore,
    count(*) as Quantita_prodotti
from dimproduct
where FinishedGoodsFlag=1
group by Color
order by Quantita_prodotti desc;
/* es 4.1 numero righe di vendita e importo totale per ciascun anno in ordine di anno crescente*/
describe factresellersales;
select 
     year(orderdate) as anno,
     count(*) as numerorighe,
     sum(salesamount) as importo_totale
from
     factresellersales
group by anno
order by anno asc;
/* 4.2 numero di riche e importo totale anno e mese */
select
     month(orderdate) as mese,
     year(orderdate) as anno,
     count(*) as numero_righe,
     sum(salesamount) as importo_totale
from factresellersales
group by mese
order by anno asc;
/* 4.3 importo totale per anno e per prodotto per anno 2013 */
select
     year(orderdate) as Anno,
     ProductKey as prodotto,
     sum(salesamount) as importo_totale
from factresellersales
where year(orderdate)=2013
group by ProductKey;
/* 5.1 importo totale per prodotto limitato ai soli prodotti il cui importo complessivo supera 100000 */
select
     ProductKey as prodotti,
     sum(salesamount) as importo_totale
from factresellersales
group by prodotti
having importo_totale > 100000;
/* 5.2 numero di righe di vendita per agente limitato algi agenti con almeno 500 righe */
select 
    EmployeeKey as agente,
    count(*) as numero_righe_vendita
 from
    factresellersales
    group by agente
    having count(*) >= 500;
-- 5.3 le due query precedenti riscritte spostando la condizione nel filtro che agisce sulle riche di dettaglio
select
    ProductKey AS Prodotto,
    SUM(SalesAmount) AS Importototale
from factresellersales
where SalesAmount > 100000
group by ProductKey;

select 
    EmployeeKey as agente,
    count(*) as numero_righe_vendita
 from
    factresellersales
    where count(*) >= 500
    group by agente;
-- Non sono corrette in quanto where filtra le righe prima dell'aggregazione mentre having dopo
-- 5.5 5 prodotti con importo totale più elevato
select 
	ProductKey as prodotto,
    sum(SalesAmount) as importototale
from factresellersales
group by productkey
order by sum(SalesAmount) desc
 limit 5;
-- 6.1 Elenco prodotti in una sola colonna, nome maiuscolo
select
   upper(EnglishProductName) as prodotto
from dimproduct;
-- 6.2 Prodotti con nome superiore a 20 caratteri + numero di caratteri
select 
   EnglishProductName as prodotto,
   length(EnglishProductName) as numeroCaratteri
from dimproduct
where length(EnglishProductName) > 20;
-- 6.3 Cognome e nome insieme + prime 3 lettere del cognome
select
     concat(LastName,FirstName) as nomeCompleto,
     substring(LastName,1,3) as aliasPrime3letterecognome
from dimemployee;
-- 6.4 Anni di servizio come numero intero
select
    firstname as Nome,
    lastname as cognome,
    timestampdiff(year,hiredate,curdate()) as anniDiServizio
from dimemployee;
-- 6.5 Data di assunzione nel formato giorno/mese/anno
select
    firstname as nome,
    lastname as cognome,
    date_format(hiredate, '%d/%m/%Y') as dataAssunzione
from dimemployee;
-- 7.1 numero di prodotti per ciascun colore query corretta
select
	color,
    count(*) as numeroProdotti
from 
	dimproduct
group by color;
-- 7.2 colori con piú di 10 prodotti
select
	color,
    count(*) as numeroProdotti
from 
	dimproduct
group by color
having  count(*)>10;
-- 7.3 colori con prezzo di listino superiore a 100
select
	color,
    avg(ListPrice) as prezzoMedio
from 
	dimproduct
group by color
having  avg(ListPrice)>100;
-- 7.4 importo totale venduto da ciascun agente in ordine decrescente
select
	EmployeeKey as IdentificativoAgente,
    sum(SalesAmount) as TotaleVenditeAgente
from 
	factresellersales
group by EmployeeKey
order by sum(SalesAmount) desc;
