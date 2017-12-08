SELECT dirname||basename,f.size,f.sha256
FROM files f
INNER JOIN
	( SELECT COUNT(*) count, g.sha256
	  FROM files g
	  GROUP BY g.sha256
	  HAVING COUNT(*) > 1 ) sel
ON f.sha256 = sel.sha256
ORDER BY f.size DESC, sel.count DESC
