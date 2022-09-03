; Подключаемые данные
ctable			DB "EXIT",0,"..Exit from DOORS",0
				DW doQuit
				DB "HELP",0,"..Show this help screen",0
				DW doHelp
				DB "CLS",0,"...Clear screen",0
				DW doCLS
				DB "SQLITE",0,"Data Base SQLite",0
				DW doSQLite
				DB "BASIC",0,".Interpretator BASIC",0
				DW doBasic
				DB 0
				
ctable_sql		DB ".EXIT",0,"Exit from SQLite",0
				DW doQuit_SQLite
				DB ".HELP",0,"Show this help screen",0
				DW doHelp_SQLite
				DB ".CLS",0,".Clear screen",0
				DW doCLS
				DB 0