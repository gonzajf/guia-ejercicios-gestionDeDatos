/* 1. Hacer una funci�n que dado un art�culo y un deposito devuelva un string que
indique el estado del dep�sito seg�n el art�culo. Si la cantidad almacenada es menor
al l�mite retornar �OCUPACION DEL DEPOSITO XX %� siendo XX el % de
ocupaci�n. Si la cantidad almacenada es mayor o igual al l�mite retornar
�DEPOSITO COMPLETO�. */
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

/* 2. Realizar una funci�n que dado un art�culo y una fecha, retorne el stock que exist�a a
esa fecha */

/* 3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en
caso que sea necesario. Se sabe que deber�a existir un �nico gerente general (deber�a
ser el �nico empleado sin jefe). Si detecta que hay m�s de un empleado sin jefe
deber� elegir entre ellos el gerente general, el cual ser� seleccionado por mayor
salario. Si hay m�s de uno se seleccionara el de mayor antig�edad en la empresa.
Al finalizar la ejecuci�n del objeto la tabla deber� cumplir con la regla de un �nico
empleado sin jefe (el gerente general) y deber� retornar la cantidad de empleados
que hab�a sin jefe antes de la ejecuci�n. */

/* 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese empleado
a lo largo del �ltimo a�o. Se deber� retornar el c�digo del vendedor que m�s vendi�
(en monto) a lo largo del �ltimo a�o. */
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

/* 9. Hacer un trigger que ante alguna modificaci�n de un �tem de factura de un art�culo
con composici�n realice el movimiento de sus correspondientes componentes. */

/* 11. Cree el/los objetos de base de datos necesarios para que dado un c�digo de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que sean
errores que su jefe directo. */