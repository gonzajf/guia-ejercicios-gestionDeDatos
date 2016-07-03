/* 1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es menor
al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de
ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”. */
create function fn1(@producto char(8), @deposito char(2)) returns varchar(255)
as
begin

declare @cantidad decimal(12,2);
declare @limite decimal(12,2);
declare @porcentaje decimal(12,2);
declare @retorno varchar(255);

select @cantidad = s.stoc_cantidad, @limite = s.stoc_stock_maximo
from STOCK s 
where s.stoc_producto = @producto
and s.stoc_deposito = @deposito

	if(@cantidad >= @limite)
		begin
			set @retorno = 'DEPOSITO COMPLETO'
		end;

	set @porcentaje = (@cantidad * 100)/@limite;

	set @retorno = concat('OCUPACION DEL DEPOSITO ES DEL ', CAST(@porcentaje as varchar(10)), ' PORCIENTO') ;

return @retorno;
end

/* 2. Realizar una función que dado un artículo y una fecha, retorne el stock que existía a
esa fecha */

/* 3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en
caso que sea necesario. Se sabe que debería existir un único gerente general (debería
ser el único empleado sin jefe). Si detecta que hay más de un empleado sin jefe
deberá elegir entre ellos el gerente general, el cual será seleccionado por mayor
salario. Si hay más de uno se seleccionara el de mayor antigüedad en la empresa.
Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla de un único
empleado sin jefe (el gerente general) y deberá retornar la cantidad de empleados
que había sin jefe antes de la ejecución. */

/* 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese empleado
a lo largo del último año. Se deberá retornar el código del vendedor que más vendió
(en monto) a lo largo del último año. */
create procedure sp4 as
begin

declare @codigoEmpleado numeric(6,0);

declare empleados cursor for 
select empl_codigo from Empleado;

open empleados;

fetch next from empleados into @codigo_empleado
	WHILE @@FETCH_STATUS = 0
	begin

	declare @total_vendido decimal(12,2)

		select @total_vendido = sum(fact_total) from Factura
		where fact_vendedor = @codigoEmpleado
		and year(fact_fecha) = 2016;

		update Empleado set empl_comision = @total_vendido where empl_codigo = @codigoEmpleado;

	fetch next from empleados into @codigo_empleado
	end

	select top 1 @codigoEmpleado = fact_vendedor from Factura
	where year(fact_fecha) = 2016
	group by fact_vendedor
	order by sum(fact_total) desc;

	return @codigoEmpleado;

CLOSE empleados;
DEALLOCATE empleados;
end
go

/* 9. Hacer un trigger que ante alguna modificación de un ítem de factura de un artículo
con composición realice el movimiento de sus correspondientes componentes. */

/* 11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que sean
errores que su jefe directo. */