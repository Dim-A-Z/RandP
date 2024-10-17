﻿
#Область ПрограммныйИнтерфейс

// Функция инициализирует настройки Компоновщик данных.
// 
// Параметры:
//   Компоновщик - КомпоновщикНастроекКомпоновкиДанных.
//   УникальныйИдентификатор - Строка.
//	 МодульОбработки - МодульОбъектаОбработки.
// 
// Возвращаемое значение:
//   АдресСКД - Строка.
// 
Функция ИнициализироватьКомпоновщик(Компоновщик, УникальныйИдентификатор, МодульОбработки) Экспорт

	СхемаКомпоновкиДанных = МодульОбработки.ПолучитьМакет("ОсновнаяСхемаКомпоновкиДанных");
	АдресСКД = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
	
	ИсточникНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСКД);
	
    Компоновщик.Инициализировать(ИсточникНастроек);
	Компоновщик.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
	Возврат АдресСКД;
	
КонецФункции // ИнициализироватьКомпоновщик()

// Функция получает при помощи СКД таблицу документов для дальнейшей фильтрации.
// 
// Параметры:
//   АдресСКД - Строка.
//   Компоновщик - КомпоновщикНастроекКомпоновкиДанных.
// 
// Возвращаемое значение:
//  ТаблицаДокументы - ТаблицаЗначений.
// 
Функция ПолучитьТаблицуДокументов(АдресСКД, Компоновщик) Экспорт

	// Получим данные по настроенной СКД
	СКД = ПолучитьИзВременногоХранилища(АдресСКД);
	
	Настройки = Компоновщик.Настройки;
		
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СКД));
	
	ДоступныеОрганизации = УправлениеДоступомБП.ОрганизацииДанныеКоторыхДоступныПользователю("Документ.АктСверкиВзаиморасчетов");
	
	СписокДоступныхОрганизаций = Новый СписокЗначений;
	Для Каждого ТекущаяОрганизация Из ДоступныеОрганизации Цикл
		СписокДоступныхОрганизаций.Добавить(ТекущаяОрганизация);
	КонецЦикла;
		
	// Добавляем отбор по списку доступных для пользователя организаций.
	ОтборПоДоступнымОрганизациям = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборПоДоступнымОрганизациям.ЛевоеЗначение 		= Новый ПолеКомпоновкиДанных("Организация");
	ОтборПоДоступнымОрганизациям.ВидСравнения 		= ВидСравненияКомпоновкиДанных.ВСписке;
	ОтборПоДоступнымОрганизациям.ПравоеЗначение 	= СписокДоступныхОрганизаций;
	ОтборПоДоступнымОрганизациям.Использование 		= Истина;
	ОтборПоДоступнымОрганизациям.РежимОтображения 	= РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто;
		
	Если ЗначениеЗаполнено(ЭтотОбъект.Организация) Тогда
		
		// Если среди доступных организаций, нет выбранной, то оставляем фильтр по доступным организациям.
		ОтборПоДоступнымОрганизациям.Использование = ДоступныеОрганизации.Найти(ЭтотОбъект.Организация) = Неопределено;	
		НовыйОтбор = БухгалтерскиеОтчетыКлиентСервер.ДобавитьОтбор(КомпоновщикНастроек, "Организация", ЭтотОбъект.Организация);
		НовыйОтбор.Представление = "###ОтборПоОрганизации###"; 
		
	КонецЕсли;
	
	КомпоновщикНастроек.Восстановить();
	
	НастройкиДляКомпоновкиМакета = КомпоновщикНастроек.ПолучитьНастройки();
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СКД,
												  НастройкиДляКомпоновкиМакета,
												  ,
												  ,
												  Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));								  
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки);
	
	ТаблицаДокументы = Новый ТаблицаЗначений;
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ТаблицаДокументы);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
	ТаблицаДокументы.Колонки.Добавить("Выбор", Новый ОписаниеТипов("Булево"));
	
	Возврат ТаблицаДокументы;
	
КонецФункции // ПолучитьТаблицуДокументов()

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция СведенияОВнешнейОбработке() Экспорт
    
    ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
    
    ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
    ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.БезопасныйРежим = "Ложь";
    
    НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
    НоваяКоманда.Представление = НСтр("ru = 'Рассылка актов сверки взаиморасчетов'");
    НоваяКоманда.Идентификатор = "РассылкаАктовСверкиВзаиморасчетов";
    НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
    НоваяКоманда.ПоказыватьОповещение = Ложь;
    
    Возврат ПараметрыРегистрации;
    
КонецФункции

#КонецОбласти
