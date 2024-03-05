﻿#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Не ЗначениеЗаполнено(Магазин) Тогда	
		 Магазин = СкладПоУмолчанию("Соловьев В.М. ЖУКОВА № 89");
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ГруппаКонтрагентов) Тогда
		ГруппаКонтрагентов = ПартнерПоУмолчанию("Сотрудники");	
	КонецЕсли;                                                
	
	Если Не ЗначениеЗаполнено(Лимит) Тогда
		Лимит = 12000;	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Партнер) Тогда
	 ОбновитьДанныеПоПартнеру();
	КонецЕсли;

КонецПроцедуры
#КонецОбласти


//////////////////////////////////////////


#Область ОбработчикиСобытийЭлементовФормы
&НаКлиенте
Процедура ПартнерПриИзменении(Элемент)
	ПартнерПриИзмененииНаСервере();
КонецПроцедуры

#КонецОбласти


//////////////////////////////////////////


#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Создать(Команда)
	СоздатьНаСервере(); 
	 ОбновитьДанныеПоПартнеру(); 
	 Если ЗначениеЗаполнено(Партнер) 
	   и Не ЗначениеЗаполнено(Соглашение) и Не ЗначениеЗаполнено(Договор) Тогда     
	   
	   СоздатьДоговорНаСервере();
	   СоздатьСоглашениеНаСервере();    
		 СоздатьКартуЛояльностиНаСервере();
	 КонецЕсли;
	 
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДоговор(Команда)
	СоздатьДоговорНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СоздатьСоглашение(Команда)
	СоздатьСоглашениеНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СоздатьКартуЛояльности(Команда)
	СоздатьКартуЛояльностиНаСервере();
КонецПроцедуры

#КонецОбласти


//////////////////////////////////////////


#Область СлужебныеПроцедурыИФункции
&НаСервере
Процедура СоздатьНаСервере()  
	
	нПартнер = Справочники.Партнеры.СоздатьЭлемент();

	нПартнер.Наименование 			= ФИО;
	нПартнер.НаименованиеПолное = ФИО;
	нПартнер.Клиент 						= Истина;
	нПартнер.ЮрФизЛицо 					= Перечисления
					.КомпанияЧастноеЛицо.ЧастноеЛицо;
	нПартнер.Родитель 					= ГруппаКонтрагентов;
	нПартнер.ДатаРегистрации		= ТекущаяДатаСеанса();
	
	Если нПартнер.ПроверитьЗаполнение() Тогда 
		нПартнер.Записать();  
		Партнер = нПартнер.Ссылка;
		ОбщегоНазначения.СообщитьПользователю(
				СтрШаблон("Новый партнер: %1, успешно создан", нПартнер));
			Иначе
				ОбщегоНазначения.СообщитьПользователю(
					"Не удалось создать партнера");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СоздатьДоговорНаСервере()
	
	нДоговор = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
	ДанныеЗаполнения = Новый Структура(
	"Наименование,
	|Организация,
	|ВидАгентскогоДоговора,
	|Партнер,
	|ПорядокРасчетов,
	|Статус,
	|ТипДоговора,
	|НалогообложениеНДС,
	|ЗакупкаПодДеятельность,
	|ПорядокОформленияСписанияНедостачПринятыхНаХранениеТоваров,
	|СпособДоставки,
	|ПеревозчикПартнер,
	|АдресДоставки,
	|ОграничиватьСуммуЗадолженности, 
	|ДопустимаяСуммаЗадолженности,     
	|ПорядокРасчетов,
	|АдресДоставкиПеревозчика");
	
	ДанныеЗаполнения.Наименование = "Отоварка";
	ДанныеЗаполнения.Организация	= ОрганизацияПоУмолчанию("Коков Вячеслав Михайлович ИП");
	ДанныеЗаполнения.ТипДоговора	= Перечисления.ТипыДоговоров.СПокупателем;
	ДанныеЗаполнения.Партнер			= Партнер;  
	ДанныеЗаполнения.ОграничиватьСуммуЗадолженности = Истина;
  ДанныеЗаполнения.ДопустимаяСуммаЗадолженности 				= Лимит;
	ДанныеЗаполнения.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоНакладным;
	
	ЗаполнитьЗначенияСвойств(нДоговор, ДанныеЗаполнения);
	нДоговор.Заполнить(ДанныеЗаполнения);
		Если нДоговор.ПроверитьЗаполнение() Тогда 
		
		
		нДоговор.Записать();  
		Договор = нДоговор.Ссылка;	
		ОбщегоНазначения.СообщитьПользователю(
				СтрШаблон("Новый Договор: %1, успешно создан", нДоговор));
			Иначе
				ОбщегоНазначения.СообщитьПользователю(
					"Не удалось создать партнера");
	КонецЕсли;

	
	
КонецПроцедуры 

&НаСервере
Процедура СоздатьСоглашениеНаСервере()  
	нСоглашение = Справочники.СоглашенияСКлиентами.СоздатьЭлемент();
	ДанныеЗаполнения = Новый Структура(
	"Наименование,
	|Партнер,
	|Организация,
	|ГрафикОплаты,
	|СуммаДокумента,
	|ВидЦен,
	|Соглашение,
	|ДатаНачалаДействия,
	|Период,
	|КоличествоПериодов,
	|Статус,
	|ХозяйственнаяОперация,
	|СпособРасчетаВознаграждения,
	|ПорядокРасчетов,
	|ИспользуютсяДоговорыКонтрагентов,
	|НеИспользуютсяДоговорыКонтрагентов,
	|ЦенаВключаетНДС,
	|ВидЦен,
	|Склад");
  	
	ДанныеЗаполнения.Наименование = ОпределитьНаименованиеПоКонтрагенту(ГруппаКонтрагентов); 
	ДанныеЗаполнения.Партнер			= Партнер; 
	ДанныеЗаполнения.Организация	= ОрганизацияПоУмолчанию("Коков Вячеслав Михайлович ИП");
	ДанныеЗаполнения.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоНакладным;
	ДанныеЗаполнения.ИспользуютсяДоговорыКонтрагентов = 1;
	ДанныеЗаполнения.НеИспользуютсяДоговорыКонтрагентов = 0;
	ДанныеЗаполнения.Склад = Магазин; 
	ДанныеЗаполнения.ЦенаВключаетНДС = Истина;  
	ДанныеЗаполнения.ВидЦен = ВидЦенПоСкладу(Магазин); 
	
	ЗаполнитьЗначенияСвойств(нСоглашение, ДанныеЗаполнения);
	
	нСоглашение.Заполнить(ДанныеЗаполнения);
	
	Если нСоглашение.ПроверитьЗаполнение() Тогда 
		нСоглашение.Записать();  
		Соглашение = нСоглашение.Ссылка;	
		ОбщегоНазначения.СообщитьПользователю(
		СтрШаблон("Новое Соглашение: %1, успешно создано", нСоглашение));
	Иначе
		ОбщегоНазначения.СообщитьПользователю(
			"Не удалось создать партнера");
	КонецЕсли;
	                                                     	                       


КонецПроцедуры 

&НаСервере
Функция СкладПоУмолчанию(Наименование)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Склады.Ссылка КАК Склад
	               |ИЗ
	               |	Справочник.Склады КАК Склады
	               |ГДЕ
	               |	Склады.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Склад;
	Иначе	 
	 	Возврат Справочники.Склады.ПустаяСсылка();
	КонецЕсли;
   
КонецФункции 

&НаСервере
Функция ПартнерПоУмолчанию(Наименование)
  Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Партнеры.Ссылка КАК Партнер
	               |ИЗ
	               |	Справочник.Партнеры КАК Партнеры
	               |ГДЕ
	               |	Партнеры.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Партнер;
	Иначе	 
	 	Возврат Справочники.Партнеры.ПустаяСсылка();
	КонецЕсли;
   
КонецФункции 

&НаСервере
Функция ОрганизацияПоУмолчанию(Наименование)
Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	Организации.Ссылка КАК Организация
	               |ИЗ
	               |	Справочник.Организации КАК Организации
	               |ГДЕ
	               |	Организации.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Организация;
	Иначе	 
	 	Возврат Справочники.Организации.ПустаяСсылка();
	КонецЕсли;

КонецФункции 

&НаСервере
Процедура ПартнерПриИзмененииНаСервере()
	ОбновитьДанныеПоПартнеру();
КонецПроцедуры

&НаСервере
Процедура ОбновитьДанныеПоПартнеру() 
	НеобходимыеДанныеПартнера = НеобходимыеДанныеПартнера(Партнер);
	
	Если НеобходимыеДанныеПартнера = Неопределено Тогда   
		Договор = Неопределено;
		Соглашение = Неопределено;
		Возврат;
	КонецЕсли;                                   
	
	Договор		 = НеобходимыеДанныеПартнера.Договор;
	Соглашение = НеобходимыеДанныеПартнера.Соглашение;
КонецПроцедуры 

&НаСервере         
Функция НеобходимыеДанныеПартнера(Партнер)
 Запрос = Новый Запрос;
 Запрос.Текст = "ВЫБРАТЬ
                |	Партнеры.Ссылка КАК Партнер
                |ПОМЕСТИТЬ втПартнеры
                |ИЗ
                |	Справочник.Партнеры КАК Партнеры
                |ГДЕ
                |	Партнеры.Ссылка = &Партнер
                |	И НЕ Партнеры.ПометкаУдаления
                |;
                |
                |////////////////////////////////////////////////////////////////////////////////
                |ВЫБРАТЬ
                |	СоглашенияСКлиентами.Ссылка КАК Соглашение,
                |	СоглашенияСКлиентами.Партнер КАК Партнер
                |ПОМЕСТИТЬ втСоглашения
                |ИЗ
                |	Справочник.СоглашенияСКлиентами КАК СоглашенияСКлиентами
                |ГДЕ
                |	НЕ СоглашенияСКлиентами.ПометкаУдаления
                |	И СоглашенияСКлиентами.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыСоглашенийСКлиентами.Действует)
                |;
                |
                |////////////////////////////////////////////////////////////////////////////////
                |ВЫБРАТЬ
                |	ДоговорыКонтрагентов.Ссылка КАК Договор,
                |	ДоговорыКонтрагентов.Партнер КАК Партнер
                |ПОМЕСТИТЬ втДоговоры
                |ИЗ
                |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
                |ГДЕ
                |	НЕ ДоговорыКонтрагентов.ПометкаУдаления
                |	И ДоговорыКонтрагентов.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыДоговоровКонтрагентов.Действует)
                |;
                |
                |////////////////////////////////////////////////////////////////////////////////
                |ВЫБРАТЬ
                |	втПартнеры.Партнер КАК Партнер,
                |	втДоговоры.Договор КАК Договор,
                |	втСоглашения.Соглашение КАК Соглашение,
                |	КартыЛояльности.Ссылка КАК КартаЛояльности,
                |	КартыЛояльности.Штрихкод КАК Штрихкод,
                |	КартыЛояльности.Статус КАК СтатусКарты
                |ИЗ
                |	втПартнеры КАК втПартнеры
                |		ЛЕВОЕ СОЕДИНЕНИЕ втСоглашения КАК втСоглашения
                |			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КартыЛояльности КАК КартыЛояльности
                |			ПО (КартыЛояльности.Соглашение = втСоглашения.Соглашение)
                |		ПО (втСоглашения.Партнер = втПартнеры.Партнер)
                |		ЛЕВОЕ СОЕДИНЕНИЕ втДоговоры КАК втДоговоры
                |		ПО втПартнеры.Партнер = втДоговоры.Партнер";
 
 Запрос.УстановитьПараметр("Партнер", Партнер);
 Результат = Запрос.Выполнить();
 
 Если Результат.Пустой() Тогда
	 Возврат Неопределено;
 КонецЕсли;            
 

 ДанныеПартнера = Результат.Выгрузить();
 
 Если ДанныеПартнера.Количество() >= 1 Тогда
 	   Возврат ОбщегоНазначения.СтрокаТаблицыЗначенийВСтруктуру(ДанныеПартнера[0]);
 КонецЕсли;

КонецФункции   

&НаСервере
Функция ВидЦенПоСкладу(Склад)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Склады.УчетныйВидЦены КАК УчетныйВидЦены
	|ИЗ
	|	Справочник.Склады КАК Склады
	|ГДЕ
	|	Склады.Ссылка = &Склад";
	
	Запрос.УстановитьПараметр("Склад", Склад);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.УчетныйВидЦены; 
	Иначе 
	  Возврат  Неопределено
	КонецЕсли;
	  
КонецФункции 

&НаСервере
Функция ОпределитьНаименованиеПоКонтрагенту(ГруппаКонтрагентов)
	
	Если ГруппаКонтрагентов.Наименование = "Сотрудники Магазинов" Тогда	
		Возврат "Продавцы";	
	КонецЕсли; 
	
	Если ГруппаКонтрагентов.Наименование = "Сотрудники" Тогда	
		Возврат "Цех";	
	КонецЕсли; 
	
	Возврат "Основное";
КонецФункции 

&НаСервере
Процедура ЗаполнитьСписокГруппКонтрагентов()
	СписокВыбора = Элементы.ГруппаКонтрагентов.СписокВыбора;
	
	СписокВыбора.Очистить();
	СписокВыбора.Добавить(ПартнерПоУмолчанию("Сотрудники")); 
	СписокВыбора.Добавить(ПартнерПоУмолчанию("Сотрудники Магазинов"));   
КонецПроцедуры 

&НаСервере
Процедура СоздатьКартуЛояльностиНаСервере()  
	нКарта = Справочники.КартыЛояльности.СоздатьЭлемент();  
	НовыйНомерШК = НовыйНомерШК(ПоследнийШКСотрудника());
	ШК = СгенерироватьШК(НовыйНомерШК);
     
	ВидКарты = Справочники.ВидыКартЛояльности.НайтиПоНаименованию("Отоварка сотрудников");
	
	ДанныеЗаполнения = Новый Структура();  	
	ДанныеЗаполнения.Вставить("Владелец"		 , ВидКарты);
	ДанныеЗаполнения.Вставить("Наименование" , СтрШаблон("%1 %2", ВидКарты.Наименование, ШК));
	ДанныеЗаполнения.Вставить("Штрихкод"		 , ШК);
	ДанныеЗаполнения.Вставить("МагнитныйКод" , Неопределено);
	ДанныеЗаполнения.Вставить("Партнер"			 , Партнер);
  ДанныеЗаполнения.Вставить("Соглашение"	 , Соглашение);

	ЗаполнитьЗначенияСвойств(нКарта, ДанныеЗаполнения);
	нКарта.Заполнить(ДанныеЗаполнения);
	
	Если нКарта.ПроверитьЗаполнение() Тогда 
		нКарта.Записать();  
		КартаЛояльности = нКарта.Ссылка;	
		ОбщегоНазначения.СообщитьПользователю(
		СтрШаблон("Новое Соглашение: %1, успешно создано", нКарта));
	Иначе
		ОбщегоНазначения.СообщитьПользователю(
			"Не удалось создать партнера");
	КонецЕсли;
КонецПроцедуры 

&НаСервере
Функция СгенерироватьШК(Номер)	
	КС = ВысчитатьКонтрольнуюСумму(Номер);
	Возврат Номер + КС;
КонецФункции 

&НаСервере
Функция ВысчитатьКонтрольнуюСумму(Номер)
	//Пример расчета контрольной цифры ean-13
	//46 79135 74987 (?)
	//Суммировать цифры на четных позициях;
	//6+9+3+7+9+7 = 41     
	//Результат пункта 1 умножить на 3;
	//41х3=123;	
	//Суммировать цифры на нечетных позициях;
	//4+7+1+5+4+8 = 29;	
	//Суммировать результаты пунктов 2 и 3;
	//123+29 = 152	
	//Контрольное число — разница между окончательной суммой и ближайшим к ней наибольшим числом, кратным 10-ти.
	//160-152 = 8
	
	СумНЧ = 0;
	СумЧЧ = 0;
	КС = 0;
		
	Для Индекс = 1 По СтрДлина(Номер) Цикл
		ТекЧисло = Число(Сред(Номер, Индекс, 1));  
		Чет = ?((Индекс % 2) = 0, Истина, Ложь);
		
		Если Чет Тогда
			//Четное	
			СумЧЧ = СумЧЧ + ТекЧисло;	
		Иначе
			//Не четное
			СумНЧ = СумНЧ + ТекЧисло;
		КонецЕсли;
		
		
	КонецЦикла;	
	
	
	ОкончательнаяСумма = ((СумЧЧ * 3) + СумНЧ); 
	МаксСуммаКратнаяДесяти = ОкончательнаяСумма; 
	
	Пока (МаксСуммаКратнаяДесяти % 10) <> 0 Цикл
	   МаксСуммаКратнаяДесяти = МаксСуммаКратнаяДесяти + 1;
	КонецЦикла;
				
	КС = МаксСуммаКратнаяДесяти - ОкончательнаяСумма;	
		
	Возврат КС;
		
КонецФункции 

&НаСервере
Функция ПоследнийШКСотрудника()
	шк = "";
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МАКСИМУМ(КартыЛояльности.Штрихкод) КАК Штрихкод
		|ИЗ
		|	Справочник.КартыЛояльности КАК КартыЛояльности";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Штрихкод;	
	Иначе 
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции 

&НаСервере
Функция НовыйНомерШК(ШК)
	Промеж = Прав(ШК, СтрДлина(ШК) - 2);
	Номер = Число(Лев(Промеж, СтрДлина(Промеж) - 1));  
	нНомер = Строка(Формат(Номер + 1, "ЧС=; ЧГ="));
	КолДобНули = 12 - СтрДлина(нНомер) - 2; // Количество добавочных нулей
	
	ДобНули = "";
	
	Для Сч = 1 По КолДобНули Цикл	
		 ДобНули = ДобНули + "0";
	КонецЦикла;
	
	
	Возврат  СтрШаблон("%1%2%3", "25", ДобНули, нНомер);     
КонецФункции 
#КонецОбласти
