-- 1.1 Elenco dei prodotti con la sottocategoria
select 
   p.productkey as codiceProdotto,
   p.englishproductname as nomeProdotto,
   ps.ProductSubcategoryKey as codiceSottocategoriaProdotto,
   ps.EnglishProductSubcategoryName as nomesottocategoriaprodotto
from dimproduct as p left join dimproductsubcategory as ps
     on p.ProductSubcategoryKey = ps.ProductSubcategoryKey;   
-- 1.2 Elenco con l'aggiunta della categoria
select 
   p.ProductKey as Codiceprodotto,
   p.EnglishProductName as NomeProdotto,
   ps.ProductSubcategoryKey as CodiceSottocategoria,
   ps.EnglishProductSubcategoryName as NomeSottocategoria,
   pc.ProductCategoryKey as CodiceCategoria,
   pc.EnglishProductCategoryName as NomeCategoria
from dimproduct as p
left join dimproductsubcategory as ps
	on p.productsubcategorykey = ps.productsubcategorykey
left join dimproductcategory as pc
    on ps.productcategorykey = pc.productcategorykey;
    
-- 2.1  Elenco dei soli prodotti venduti almeno una volta
select distinct
	p.ProductKey as codiceprodotto,
    p.EnglishProductName as nomeprodotto,
case
    when p.FinishedGoodsFlag=1 then 'si'
    else 'no'
end as prodottoCompletato
from dimproduct as p
inner join factresellersales as v
   on p.productkey = v.productkey;
-- 2.2 Elenco dei prodotti finiti mai venduti
select
	p.ProductKey as codiceprodott,
    p.EnglishProductName as nomeprodotto,
case
    when p.FinishedGoodsFlag=1 then 'si'
    else 'no'
end as prodottoCompletato
from dimproduct as p
left join factresellersales as v
	on p.productkey + v.productkey
where v.productkey is null
	and p.finishedgoodsflag=1;
-- 3.1 Transazioni di vendita con il nome del prodotto

select 
	frs.*,
    p.EnglishProductName
from factresellersales as frs
left join dimproduct as p
	on frs.productkey = p.productkey;
    
-- 3.2 Transazioni con nome prodotto + categoria

select 
	frs.*,
    p.EnglishProductName,
    c.EnglishProductCategoryName
from factresellersales as frs
left join dimproduct as p
	on frs.productkey = p.productkey
left join dimproductsubcategory as sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
left join dimproductcategory as c
	on sc.ProductCategoryKey = c.ProductCategoryKey;
    
-- 4.1 Elenco dei reseller con l'area geografica di appartenenza

select 
	dr.ResellerName,
    dg.EnglishCountryRegionName,
    dg.StateProvinceName,
    dg.City
from dimreseller dr
left join dimgeography dg
	on dr.GeographyKey = dg.GeographyKey;
    
-- 4.2 Numero di reseller per area geografica, ordinato dal più numeroso

select
	dg.EnglishCountryRegionName as areaGeografica,
    count(dr.ResellerKey) as numeroReseller
from dimreseller dr
left join dimgeography dg
	on dr.GeographyKey = dg.GeographyKey
group by dg.EnglishCountryRegionName
order by numeroReseller desc;

-- 5 Elenco delle transazioni di vendita con: numero e riga d'ordine, data, prezzo unitario, quantità e costo del prodotto, nome del prodotto, categoria del prodotto, nome del reseller, area geografica.
select
	s.SalesOrderNumber as numeroOrdine,
    s.salesorderlinenumber as linea,
    s.orderdate as dataordine,
    s.unitprice as prezzounitario,
    s.orderquantity as quantitaOrdine,
    s.totalproductcost as costoTotProduzione,
    p.englishproductname as NomeProdotto,
    c.englishproductcategoryname as Categoria,
    r.resellername as Rivenditore,
    g.englishcountryregionname as ZonaGeografica
from factresellersales s
join dimproduct p
	on s.ProductKey = p.ProductKey
join dimproductsubcategory sc
	on p.ProductSubcategoryKey = sc.ProductSubcategoryKey
join dimproductcategory c
	on sc.ProductSubcategoryKey = c.ProductCategoryKey
join dimreseller r
	on s.ResellerKey = r.ResellerKey
join dimgeography g
	on g.GeographyKey = r.GeographyKey;

-- 6.1 Importo totale venduto per categoria di prodotto	
select
	c.EnglishProductCategoryName Categoria,
    sum(s.salesamount) as TotaleVenduto
from factresellersales s
join dimproduct p
	on p.ProductKey = s.ProductKey
join dimproductsubcategory sc
	on sc.ProductSubcategoryKey = p.ProductSubcategoryKey
join dimproductcategory c
	on c.ProductCategoryKey = sc.ProductCategoryKey
group by
	c.EnglishProductCategoryName
order by
	TotaleVenduto desc;
    
-- 6.2 numero transazioni per area geografica
select
	g.EnglishCountryRegionName as AreaGeografica,
    count(*) NumeroTransazioni
from factresellersales s
	join dimreseller r
on r.ResellerKey = s.ResellerKey
	join dimgeography g
on g.GeographyKey = r.GeographyKey
group by 
	g.EnglishCountryRegionName
order by
	NumeroTransazioni;
	
