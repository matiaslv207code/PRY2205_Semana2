-- Caso 1 analisis de facturas
SELECT 
    numfactura AS "N° Factura",
    TO_CHAR(fecha, 'DD "de" MONTH YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emisión",
    LPAD(rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(neto, '$999G999G999') AS "Monto Neto",
    TO_CHAR(iva, '$999G999G999') AS "Monto Iva",
    TO_CHAR(total, '$999G999G999') AS "Total Factura",
    CASE 
        WHEN total BETWEEN 0 AND 50000 THEN 'Bajo'
        WHEN total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",
    DECODE(codpago, 
        1, 'EFECTIVO', 
        2, 'TARJETA DEBITO', 
        3, 'TARJETA CREDITO', 
        'CHEQUE'
    ) AS "Forma de pago"
FROM factura
WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha DESC, neto DESC;

-- Caso 2 clasificacion de clientes
SELECT 
    LPAD(rutcliente, 12, '*') AS "RUT",
    INITCAP(nombre) AS "Cliente",
    NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
    estado AS "ESTADO",
    CASE 
        WHEN (saldo / credito) < 0.5 THEN 'Bueno ( ' || TO_CHAR(credito - saldo, '$999G999G999') || ')'
        WHEN (saldo / credito) BETWEEN 0.5 AND 0.8 THEN 'Regular ( ' || TO_CHAR(saldo, '$999G999G999') || ')'
        ELSE 'Crítico'
    END AS "Estado Crédito",
    NVL(SUBSTR(mail, INSTR(mail, '@') + 1), 'Correo no registrado') AS "Dominio Correo"
FROM cliente
WHERE estado = 'A' AND credito > 0
ORDER BY nombre ASC;

-- Caso 3 stock de productos
SELECT 
    codproducto AS "ID",
    descripcion AS "Descripción de Producto",
    NVL(TO_CHAR(valorcompradolar, '99G999D99', 'NLS_NUMERIC_CHARACTERS = '',.""'), 'Sin registro') || ' USD' AS "Compra en USD",
    NVL(TO_CHAR(valorcompradolar * 950, '$999G999G999'), 'Sin registro') || ' PESOS' AS "USD convertido",
    NVL(TO_CHAR(totalstock), 'Sin datos') AS "Stock",
    CASE 
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < 40 THEN '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN 40 AND 60 THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE 
        WHEN totalstock > 80 THEN TO_CHAR(vunitario - (vunitario * 0.10), '$999G999G999')
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM producto
WHERE LOWER(descripcion) LIKE '%zapato%' AND UPPER(procedencia) = 'I'
ORDER BY codproducto DESC;