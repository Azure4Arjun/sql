
;WITH mycte AS (SELECT OBJECT_NAME(i2.object_id) AS 'TableName',STUFF(
			(SELECT ',' + COL_NAME(ic.object_id,ic.column_ID) 
			FROM sys.indexes i1
			INNER JOIN sys.index_columns ic ON i1.object_id = ic.object_id
				AND i1.index_id = ic.index_id
			WHERE i1.is_primary_key = 1
				AND i1.object_id = i2.object_id	AND i1.index_id = i2.index_id
			FOR XML PATH('')),1,1,'') AS PK
FROM sys.indexes i2
	INNER JOIN sys.objects o ON i2.object_id = o.object_id
WHERE i2.is_primary_key = 1
	AND o.type_desc = 'USER_TABLE'
)
SELECT OBJECT_NAME(i.object_id) AS 'TableName',COUNT(COL_NAME(ic.object_id,ic.column_id)) AS 'Primary_Key_Column_Count', MAX(mycte.PK) AS 'Primary_Key_Columns'
	FROM sys.indexes i 
		INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
		INNER JOIN sys.objects o ON i.object_id = o.object_ID
		INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
		INNER JOIN mycte ON mycte.TableName = OBJECT_NAME(i.object_id)
	WHERE i.is_primary_key = 1
		AND o.type_desc = 'USER_TABLE'
GROUP BY OBJECT_NAME(i.object_id)
HAVING COUNT(1) > 1
ORDER BY 1