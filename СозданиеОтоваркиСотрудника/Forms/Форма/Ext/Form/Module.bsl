﻿#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ЗначениеЗаполнено(Магазин) Тогда	
		 Магазин = СкладПоУмолчанию("Соловьев В.М. ЖУКОВА № 89");
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ГруппаКонтрагентов) Тогда
		ГруппаКонтрагентов = ПартнерПоУмолчанию("Сотрудники");	
	КонецЕсли;                                                
	
	Если Не ЗначениеЗаполнено(Лимит) Тогда
		Лимит = 12000;	
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


//////////////////////////////////////////


#Область ОбработчикиСобытийЭлементовФормы

#КонецОбласти


//////////////////////////////////////////


#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Создать(Команда)
	СоздатьНаСервере();
КонецПроцедуры


&НаКлиенте
Процедура СоздатьДоговор(Команда)
	СоздатьДоговорНаСервере();
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
	|ФиксированнаяСуммаДоговора, 
	|Сумма,     
	|ПорядокРасчетов,
	|АдресДоставкиПеревозчика");
	
	ДанныеЗаполнения.Наименование = "Отоварка";
	ДанныеЗаполнения.Организация	= ОрганизацияПоУмолчанию("Коков Вячеслав Михайлович ИП");
	ДанныеЗаполнения.ТипДоговора	= Перечисления.ТипыДоговоров.СПокупателем;
	ДанныеЗаполнения.Партнер			= Партнер;  
	ДанныеЗаполнения.ФиксированнаяСуммаДоговора = Истина;
  ДанныеЗаполнения.Сумма 				= Лимит;
	ДанныеЗаполнения.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоНакладным;
	
	ЗаполнитьЗначенияСвойств(нДоговор, ДанныеЗаполнения);
	нДоговор.Заполнить(ДанныеЗаполнения);
		Если нДоговор.ПроверитьЗаполнение() Тогда 
		
		
		нДоговор.Записать();  
		Договор = нДоговор.Ссылка;	
		ОбщегоНазначения.СообщитьПользователю(
				СтрШаблон("Новый партнер: %1, успешно создан", нДоговор));
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

#КонецОбласти
