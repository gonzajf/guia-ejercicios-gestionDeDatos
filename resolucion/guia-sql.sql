--PRACTICA SQL
/* Mostrar el c�digo, raz�n social de todos los clientes cuyo l�mite de cr�dito sea
mayor o igual a $ 1000 ordenado por c�digo de cliente. */
select clie_codigo, clie_razon_social
from Cliente c
where clie_limite_credito >= 1000
order by clie_codigo

/* 2. Mostrar el c�digo, detalle de todos los art�culos vendidos en el a�o 2012 ordenados
por cantidad vendida. */
select item_producto, p.prod_detalle, cant_vendida= sum(i.item_cantidad)
from Item_Factura i
join Factura f on (i.item_tipo = f.fact_tipo 
					and i.item_sucursal = f.fact_sucursal
					and i.item_numero = f.fact_numero) 
join Producto p on i.item_producto = p.prod_codigo
where f.fact_fecha >= '2012-01-01' and f.fact_fecha <= '2012-31-12'
group by item_producto, prod_detalle
order by cant_vendida

/* 3. Realizar una consulta que muestre c�digo de producto, nombre de producto y el
stock total, sin importar en que deposito se encuentre, los datos deben ser ordenados
por nombre del art�culo de menor a mayor. */
select p.prod_codigo, p.prod_detalle, stock = sum(s.stoc_cantidad)
from Producto p
join STOCK s on(p.prod_codigo = s.stoc_producto)
group by p.prod_codigo, p.prod_detalle
order by  p.prod_detalle asc

/* 4. Realizar una consulta que muestre para todos los art�culos c�digo, detalle y cantidad
de art�culos que lo componen. Mostrar solo aquellos art�culos para los cuales el
stock promedio por dep�sito sea mayor a 100. */
select comp_producto, prod_detalle, cantidad=sum(comp_cantidad)
from Composicion
join Producto on prod_codigo = comp_producto
group by comp_producto, prod_detalle, comp_componente
having(select avg(stoc_cantidad) from STOCK
		where stoc_producto = comp_producto)>100


/* 5. Realizar una consulta que muestre c�digo de art�culo, detalle y cantidad de egresos
de stock que se realizaron para ese art�culo en el a�o 2012 (egresan los productos
que fueron vendidos). Mostrar solo aquellos que hayan tenido m�s egresos que en el
2011. */
select p.prod_codigo, p.prod_detalle, ventas_2012=sum(i.item_cantidad)
from Item_Factura i 
join Factura f on (f.fact_tipo = i.item_tipo 
					and f.fact_sucursal = i.item_sucursal
					and f.fact_numero = i.item_numero)
join Producto p on i.item_producto = p.prod_codigo
where year(f.fact_fecha) = 2012
group by p.prod_codigo, p.prod_detalle
having sum(i.item_cantidad) > (select sum(i2.item_cantidad)
								from Item_Factura i2 
								join Factura f2 on (f2.fact_tipo = i2.item_tipo 
													and f2.fact_sucursal = i2.item_sucursal
													and f2.fact_numero = i2.item_numero)
								join Producto p2 on i2.item_producto = p2.prod_codigo
								where year(f2.fact_fecha) = 2011 and
								p2.prod_codigo = p.prod_codigo
								group by p2.prod_codigo, p2.prod_detalle)

/* 6. Mostrar para todos los rubros de art�culos c�digo, detalle, cantidad de art�culos de
ese rubro y stock total de ese rubro de art�culos. Solo tener en cuenta aquellos
art�culos que tengan un stock mayor al del art�culo �00000000� en el dep�sito �00�. */
select r.rubr_id, r.rubr_detalle, cant_productos = COUNT(distinct p.prod_codigo), stock_total=sum(s.stoc_cantidad)
from Producto p
join Rubro r on r.rubr_id = p.prod_rubro
left join STOCK s on s.stoc_producto = p.prod_codigo
group by r.rubr_id, r.rubr_detalle
having sum(s.stoc_cantidad) >(
			select stoc_cantidad
			from STOCK
			where stoc_producto = '00000000' and stoc_deposito = '00')


/* 7. Generar una consulta que muestre para cada articulo c�digo, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio
= 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos art�culos que
posean stock. */
select p.prod_codigo, 
		p.prod_detalle, 
		minimo=min(i.item_precio), 
		maximo=max(i.item_precio),
		porcentaje_diferencia = (((max(i.item_precio)-min(i.item_precio)))/(min(i.item_precio)))*100
from Producto p
join Item_Factura i on p.prod_codigo = i.item_producto
where p.prod_codigo in (select p1.prod_codigo
						from Producto p1
						join STOCK s on p1.prod_codigo = s.stoc_producto
						group by p1.prod_codigo
						having sum (stoc_cantidad) > 0)
group by p.prod_codigo, p.prod_detalle

/* Mostrar para el o los art�culos que tengan stock en todos los dep�sitos, nombre del
art�culo, stock del dep�sito que m�s stock tiene. */

select prod_detalle, depositoQueMasTiene = max(stoc_cantidad)
from Producto
join STOCK on prod_codigo = stoc_producto
group by prod_detalle
having count(distinct stoc_deposito) = (select count(*) from DEPOSITO)

/* Mostrar el c�digo del jefe, c�digo del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de dep�sitos que ambos tienen asignados. */
select empl_jefe, 
		empl_codigo, 
		RTRIM(empl_nombre)+' '+empl_apellido as Nombre,
		cant_depo_jefe = (select count(*) from DEPOSITO where depo_encargado = empl_jefe),
		cant_depo_empleado = (select count(*) from DEPOSITO where depo_encargado = empl_codigo)
from Empleado

/* 10. Mostrar los 10 productos mas vendidos en la historia y tambi�n los 10 productos
menos vendidos en la historia. Adem�s mostrar de esos productos, quien fue el
cliente que mayor compra realizo. */
select top 10 i.item_producto, 
				p.prod_detalle, 
				cantidad_compra = sum(i.item_cantidad),
				clienteQueMasCompro = (select top 1 clie_codigo
											from Item_Factura i1
											join Factura f1 on (i1.item_tipo = f1.fact_tipo AND i1.item_sucursal = f1.fact_sucursal AND i1.item_numero = f1.fact_numero)
											join Cliente on clie_codigo = f1.fact_cliente
											where i1.item_producto = i.item_producto
											group by i1.item_producto, clie_codigo
											order by sum(i1.item_cantidad) desc)
from Item_Factura i
join Factura f on (i.item_tipo = f.fact_tipo AND i.item_sucursal = f.fact_sucursal AND i.item_numero = f.fact_numero)
join Producto p on (i.item_producto = p.prod_codigo)
where p.prod_codigo in (select top 10 item_producto
						from Item_Factura i1
						join Factura f1 on (i1.item_tipo = f1.fact_tipo AND i1.item_sucursal = f1.fact_sucursal AND i1.item_numero = f1.fact_numero)
						group by i1.item_producto
						order by sum(i1.item_cantidad) desc)
group by i.item_producto, p.prod_detalle

union all

select top 10 i.item_producto, 
				p.prod_detalle, 
				cantidad_compra = sum(i.item_cantidad),
				clienteQueMasCompro = (select top 1 clie_codigo
											from Item_Factura i1
											join Factura f1 on (i1.item_tipo = f1.fact_tipo AND i1.item_sucursal = f1.fact_sucursal AND i1.item_numero = f1.fact_numero)
											join Cliente on clie_codigo = f1.fact_cliente
											where i1.item_producto = i.item_producto
											group by i1.item_producto, clie_codigo
											order by sum(i1.item_cantidad) asc)
from Item_Factura i
join Factura f on (i.item_tipo = f.fact_tipo AND i.item_sucursal = f.fact_sucursal AND i.item_numero = f.fact_numero)
join Producto p on (i.item_producto = p.prod_codigo)
where p.prod_codigo in (select top 10 item_producto
						from Item_Factura i1
						join Factura f1 on (i1.item_tipo = f1.fact_tipo AND i1.item_sucursal = f1.fact_sucursal AND i1.item_numero = f1.fact_numero)
						group by i1.item_producto
						order by sum(i1.item_cantidad) asc)
group by i.item_producto, p.prod_detalle

/* 11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deber�n
ordenar de mayor a menor, por la familia que m�s productos diferentes vendidos
tenga, solo se deber�n mostrar las familias que tengan una venta superior a 20000
pesos para el a�o 2012. */
select fami_detalle, count(distinct prod_codigo), sum(fact_total)
from Familia
join Producto on fami_id = prod_familia
join Item_Factura on prod_codigo = item_producto
join Factura on (item_tipo = fact_tipo and item_sucursal = fact_sucursal
				and item_numero = fact_numero)
where year(fact_fecha) = 2012
group by fami_detalle
having (sum(fact_total)) > 20000
order by 3 desc

/* 12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron
importe promedio pagado por el producto, cantidad de dep�sitos en lo cuales hay
stock del producto y stock actual del producto en todos los dep�sitos. Se deber�n
mostrar aquellos productos que hayan tenido operaciones en el a�o 2012 y los datos
deber�n ordenarse de mayor a menor por monto vendido del producto. */
select prod_detalle, 
		cantidadClientes = count(distinct fact_cliente), 
		promedioPagado = avg(item_precio),
		cantidadDepositosConStock = (select count(distinct stoc_deposito) from STOCK
										where stoc_producto = prod_codigo),
		cantidadStockTotal = (select sum(stoc_cantidad) from Stock 
								where stoc_producto = prod_codigo)
from Producto
join Item_Factura on prod_codigo = item_producto
join Factura on (item_tipo = fact_tipo and item_sucursal = fact_sucursal
				and item_numero = fact_numero)
where prod_codigo in (select distinct prod_codigo 
						from Producto
						join Item_Factura on prod_codigo = item_producto
						join Factura on (item_tipo = fact_tipo and item_sucursal = fact_sucursal
										and item_numero = fact_numero)
						where year(fact_fecha) = 2012)
group by prod_detalle, prod_codigo
order by 3 desc

/* 13. Realizar una consulta que retorne para cada producto que posea composici�n
nombre del producto, precio del producto, precio de la sumatoria de los precios por
la cantidad de los productos que lo componen. Solo se deber�n mostrar los
productos que est�n compuestos por m�s de 2 productos y deben ser ordenados de
mayor a menor por cantidad de productos que lo componen. */
select pr.prod_detalle, 
	pr.prod_precio, 
	sumaPresioComponentes = sum(comp.prod_precio * c.comp_cantidad) 
from producto pr
join composicion c on c.comp_producto = pr.prod_codigo
join producto comp on c.comp_componente = comp.prod_codigo
group by pr.prod_detalle, pr.prod_precio
having sum(c.comp_cantidad) > 2
order by sum(c.comp_cantidad) desc

/* 14. Escriba una consulta que retorne una estad�stica de ventas por cliente. Los campos
que debe retornar son:
C�digo del cliente
Cantidad de veces que compro en el �ltimo a�o
Promedio por compra en el �ltimo a�o
Cantidad de productos diferentes que compro en el �ltimo a�o
Monto de la mayor compra que realizo en el �ltimo a�o
Se deber�n retornar todos los clientes ordenados por la cantidad de veces que
compro en el �ltimo a�o.
No se deber�n visualizar NULLs en ninguna columna */
select clie_codigo, 
		cant_compras = isNull(count(fact_cliente),0), 
		prodCompradosDistintos = isnull(count(distinct item_producto),0), 
		promedioComprado = isnull(avg(fact_total),0), 
		maximaCompra = isnull(max(fact_total),0)
from Cliente
join Factura on clie_codigo = fact_cliente
join Item_Factura on item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
where year(fact_fecha) = 2012
group by clie_codigo
order by count(fact_cliente) desc

/* 15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos
juntos (en la misma factura) m�s de 500 veces. El resultado debe mostrar el c�digo
y descripci�n de cada uno de los productos y la cantidad de veces que fueron
vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se
vendieron juntos dichos productos. Los distintos pares no deben retornarse m�s de
una vez.
Ejemplo de lo que retornar�a la consulta:
PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2 */
select p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_detalle, COUNT (*) as Cantidad
from Producto p1, Producto p2, Item_Factura i, Item_Factura i2
where p1.prod_codigo=i.item_producto and
p2.prod_codigo=i2.item_producto and
i.item_numero=i2.item_numero and
p1.prod_codigo > p2.prod_codigo
group by p1.prod_codigo, p1.prod_detalle, p2.prod_codigo, p2.prod_detalle
having COUNT (*) > 500 



