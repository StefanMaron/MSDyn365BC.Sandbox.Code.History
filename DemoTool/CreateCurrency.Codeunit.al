codeunit 101004 "Create Currency"
{
    // // To change or update exchange rates, please change the values in the CurrencyData.txt file
    // //in the pictures folder.

    TableNo = "Temporary Currency Data";

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        Reset();
        if FindSet() then
            repeat
                if (DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended) or
                   ((DemoDataSetup."Data Type" <> DemoDataSetup."Data Type"::Extended) and ("Currency Code" in ['USD', 'EUR', 'CAD', 'MXN']))
                then begin
                    InsertData(Rec);
                    InsertExchRateData(Rec);
                end;
            until Next() = 0
        else
            Error(NoCurrencyFoundErr);

        if not Skip then begin
            DemoDataSetup.TestField("Currency Code");
            TempCurrencyData.Get(DemoDataSetup."Currency Code");
            DemoDataSetup.Validate("Local Precision Factor", TempCurrencyData."Local Precision Factor");
            DemoDataSetup."Local Currency Factor" :=
              Round(TempCurrencyData."Exchange Rate Amount" / TempCurrencyData."Relational Exch. Rate Amount", 0.0001);
            DemoDataSetup.Modify();

            "Create Currency Exchange Rate".LocalizeExchangeRates();

            SetLCYinGLSetup(DemoDataSetup."Currency Code");
        end;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        Currency: Record Currency;
        TempCurrencyData: Record "Temporary Currency Data";
        CA: Codeunit "Make Adjustments";
        "Create Currency Exchange Rate": Codeunit "Create Currency Exchange Rate";
        Skip: Boolean;
        XEuro: Label 'Euro';
        XAustraliandollar: Label 'Australian dollar';
        XBulgarianleva: Label 'Bulgarian leva';
        XBruneiDarussalemdollar: Label 'Brunei Darussalem dollar';
        XBrazilianreal: Label 'Brazilian real';
        XCanadiandollar: Label 'Canadian dollar';
        XCroatianKuna: Label 'Croatian Kuna';
        XSwissfranc: Label 'Swiss franc';
        XCzechkoruna: Label 'Czech koruna';
        XDanishkrone: Label 'Danish krone';
        XEstoniankroon: Label 'Estonian kroon';
        XFijidollar: Label 'Fiji dollar';
        XBritishpound: Label 'Pound Sterling';
        XHongKongdollar: Label 'Hong Kong dollar';
        XIndonesianrupiah: Label 'Indonesian rupiah';
        XJapaneseyen: Label 'Japanese yen';
        XIndianrupee: Label 'Indian rupee';
        XIcelandickrona: Label 'Icelandic krona';
        XMalaysianringgit: Label 'Malaysian ringgit';
        XMexicanpeso: Label 'Mexican peso';
        XNorwegiankrone: Label 'Norwegian krone';
        XNewZealanddollar: Label 'New Zealand dollar';
        XPhilippinespeso: Label 'Philippines peso';
        XPolishzloty: Label 'Polish zloty';
        XRussianruble: Label 'Russian ruble';
        XSwedishkrona: Label 'Swedish krona';
        XSingaporedollar: Label 'Singapore dollar';
        XSloveniantolar: Label 'Slovenian tolar';
        XSaudiArabianryial: Label 'Saudi Arabian ryial';
        XSolomonIslandsdollar: Label 'Solomon Islands dollar';
        XThaibaht: Label 'Thai baht';
        XUSdollar: Label 'US dollar';
        XVanuatuvatu: Label 'Vanuatu vatu';
        XWesternSamoantala: Label 'Western Samoan tala';
        XSouthAfricanrand: Label 'South African rand';
        XUnitedArabEmiratesdirham: Label 'United Arab Emirates dirham';
        XAlgeriandinar: Label 'Algerian dinar';
        XHungarianforint: Label 'Hungarian forint';
        XKenyanShilling: Label 'Kenyan Shilling';
        XMoroccandirham: Label 'Moroccan dirham';
        XMozambiquemetical: Label 'Mozambique metical';
        XNigeriannaira: Label 'Nigerian naira';
        XRomanianleu: Label 'Romanian leu';
        XSwazilandlilangeni: Label 'Swaziland lilangeni';
        XSlovakKoruna: Label 'Slovak Koruna';
        XSerbianDinar: Label 'Serbian Dinar';
        XTunesiandinar: Label 'Tunesian dinar';
        XUgandanShilling: Label 'Ugandan Shilling';
        XMacedonianDenarTxt: Label 'Macedonian Denar';
        XChineseYuanTxt: Label 'Chinese Yuan';
        NoCurrencyFoundErr: Label 'No currency was found, can not continue.';
        XNewTurkishlira: Label 'New Turkish lira';
        CountryCodeDoesNotExistErr: Label 'Currency code does not exist, can not continue.';
        XTonganPaanga: Label 'Tongan Pa anga';
        XFrenchPacificFranc: Label 'French Pacific Franc';

    procedure InsertData(CurrencyData: Record "Temporary Currency Data")
    begin
        Currency.Init();
        Currency.Validate(Code, CurrencyData."Currency Code");
        Currency.Validate("ISO Code", CopyStr(Currency.Code, 1, 3));
        Currency.Validate("ISO Numeric Code", CurrencyData."ISO Numeric Code");
        Currency.Validate(Description, GetCurrencyDescription(CurrencyData."Currency Code"));
        Currency.Validate("Amount Rounding Precision", CurrencyData."Amount Rounding Precision");
        Currency.Validate("Unit-Amount Rounding Precision", CurrencyData."Unit-Amount Rounding Precision");
        Currency.Validate("Invoice Rounding Precision", CurrencyData."Invoice Rounding Precision");
        Currency.Validate("Invoice Rounding Type", CurrencyData."Invoice Rounding Type");
        Currency.Validate("EMU Currency", CurrencyData."EMU Currency");
        Currency.Validate("Amount Decimal Places", CurrencyData."Amount Decimal Places");
        Currency.Validate("Unit-Amount Decimal Places", CurrencyData."Unit-Amount Decimal Places");
        Currency.Validate(Symbol, Currency.ResolveCurrencySymbol(Currency.Code));
        Currency.Insert(true);
    end;

    procedure InsertExchRateData(TemporaryCurrencyData: Record "Temporary Currency Data")
    begin
        if Skip then
            exit;

        "Create Currency Exchange Rate".InsertData(
              TemporaryCurrencyData."Currency Code", CalcDate('<CY-2Y+1D>', WorkDate()), TemporaryCurrencyData."Exchange Rate Amount", TemporaryCurrencyData."Exchange Rate Amount",
              '', TemporaryCurrencyData."Relational Exch. Rate Amount", 0, TemporaryCurrencyData."Relational Exch. Rate Amount");
    end;

    procedure GetBusPostingGroup("Country Code": Code[10]): Code[10]
    begin
        if DemoDataSetup."Country/Region Code" = '' then
            DemoDataSetup.Get();

        case "Country Code" of
            '', DemoDataSetup."Country/Region Code":
                exit(DemoDataSetup.DomesticCode());
            'AT', 'BE', 'BG', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
          'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB':
                exit(DemoDataSetup.EUCode());
            else
                exit(DemoDataSetup.ExportCode());
        end;
    end;

    procedure GetPostingGroup("Country Code": Code[10]): Code[10]
    begin
        if DemoDataSetup."Country/Region Code" = '' then
            DemoDataSetup.Get();

        case "Country Code" of
            '', DemoDataSetup."Country/Region Code":
                exit(DemoDataSetup.DomesticCode());
            'AT', 'BE', 'BG', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
          'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB':
                exit(DemoDataSetup.EUCode());
            else
                exit(DemoDataSetup.ForeignCode());
        end;
    end;

    procedure ModifyData()
    var
        "G/L Account": Record "G/L Account";
        GetGLAccountNo: Codeunit "Get G/L Account No. and Name";
    begin
        DemoDataSetup.Get();
        Currency.Reset();
        if Currency.Find('-') then
            repeat
                if DemoDataSetup."Data Type" = DemoDataSetup."Data Type"::Extended then begin
                    Currency.Validate("Unrealized Gains Acc.", CA.Convert('999310'));
                    Currency.Validate("Unrealized Losses Acc.", CA.Convert('999320'));
                    Currency.Validate("Realized Gains Acc.", CA.Convert('999330'));
                    Currency.Validate("Realized Losses Acc.", CA.Convert('999340'));
                    if DemoDataSetup."Additional Currency Code" = Currency.Code then begin
                        Currency.Validate("Realized G/L Gains Account", CA.Convert('999330'));
                        Currency.Validate("Realized G/L Losses Account", CA.Convert('999340'));
                        Currency.Validate("Residual Gains Account", CA.Convert('999350'));
                        Currency.Validate("Residual Losses Account", CA.Convert('999360'));
                        "G/L Account".SetFilter("No.", '%1|%2|%3|%4|%5|%6|%7|%8',
                          CA.Convert('992310'), CA.Convert('992320'), CA.Convert('995410'), CA.Convert('995420'),
                          CA.Convert('999310'), CA.Convert('999320'), CA.Convert('999330'), CA.Convert('999340'));
                        "G/L Account".ModifyAll("Exchange Rate Adjustment", 2);
                    end;
                end
                else begin
                    Currency.Validate("Unrealized Gains Acc.", GetGLAccountNo.UnrealizedFXGains());
                    Currency.Validate("Unrealized Losses Acc.", GetGLAccountNo.UnrealizedFXLosses());
                    Currency.Validate("Realized Gains Acc.", GetGLAccountNo.RealizedFXGains());
                    Currency.Validate("Realized Losses Acc.", GetGLAccountNo.RealizedFXLosses());
                end;
                Currency.Modify();
            until Currency.Next() = 0;
    end;

    procedure SkipDemoDataSetup(NewSkip: Boolean)
    begin
        Skip := NewSkip;
    end;

    procedure GetCurrencyDescription(CurrencyCode: Code[10]): Text[30]
    begin
        DemoDataSetup.Get();
        case CurrencyCode of
            'AED':
                exit(XUnitedArabEmiratesdirham);
            'AUD':
                exit(XAustraliandollar);
            'BGN':
                exit(XBulgarianleva);
            'BND':
                exit(XBruneiDarussalemdollar);
            'BRL':
                exit(XBrazilianreal);
            'CAD':
                exit(XCanadiandollar);
            'CHF':
                exit(XSwissfranc);
            'CNY':
                exit(XChineseYuanTxt);
            'CZK':
                exit(XCzechkoruna);
            'DKK':
                exit(XDanishkrone);
            'DZD':
                exit(XAlgeriandinar);
            'EEK':
                exit(XEstoniankroon);
            'EUR':
                exit(XEuro);
            'FJD':
                exit(XFijidollar);
            'GBP':
                exit(XBritishpound);
            'HKD':
                exit(XHongKongdollar);
            'HRK':
                exit(XCroatianKuna);
            'HUF':
                exit(XHungarianforint);
            'IDR':
                exit(XIndonesianrupiah);
            'INR':
                exit(XIndianrupee);
            'ISK':
                exit(XIcelandickrona);
            'JPY':
                exit(XJapaneseyen);
            'KES':
                exit(XKenyanShilling);
            'MAD':
                exit(XMoroccandirham);
            'MKD':
                exit(XMacedonianDenarTxt);
            'MXN':
                exit(XMexicanpeso);
            'MYR':
                exit(XMalaysianringgit);
            'MZN':
                exit(XMozambiquemetical);
            'NGN':
                exit(XNigeriannaira);
            'NOK':
                exit(XNorwegiankrone);
            'NZD':
                exit(XNewZealanddollar);
            'PHP':
                exit(XPhilippinespeso);
            'PLN':
                exit(XPolishzloty);
            'RON':
                exit(XRomanianleu);
            'RSD':
                exit(XSerbianDinar);
            'RUB':
                exit(XRussianruble);
            'SAR':
                exit(XSaudiArabianryial);
            'SBD':
                exit(XSolomonIslandsdollar);
            'SEK':
                exit(XSwedishkrona);
            'SGD':
                exit(XSingaporedollar);
            'SIT':
                exit(XSloveniantolar);
            'SKK':
                exit(XSlovakKoruna);
            'SZL':
                exit(XSwazilandlilangeni);
            'THB':
                exit(XThaibaht);
            'TND':
                exit(XTunesiandinar);
            'TOP':
                exit(XTonganPaanga);
            'TRY':
                exit(XNewTurkishlira);
            'UGX':
                exit(XUgandanShilling);
            'USD':
                exit(XUSdollar);
            'VUV':
                exit(XVanuatuvatu);
            'WST':
                exit(XWesternSamoantala);
            'XPF':
                exit(XFrenchPacificFranc);
            'ZAR':
                exit(XSouthAfricanrand);
            '':
                exit('');
            else
                Error(CountryCodeDoesNotExistErr);
        end;
    end;

    local procedure SetLCYinGLSetup(LCYCurrencyCode: Code[10])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        Currency.Get(LCYCurrencyCode);
        GLSetup.Get();
        GLSetup.Validate("LCY Code", Currency.Code);
        GLSetup.Validate("Local Currency Description", GetCurrencyDescription(LCYCurrencyCode));
        GLSetup."Inv. Rounding Precision (LCY)" := Currency."Invoice Rounding Precision";
        GLSetup."Amount Rounding Precision" := Currency."Amount Rounding Precision";
        GLSetup."Unit-Amount Rounding Precision" := Currency."Unit-Amount Rounding Precision";
        GLSetup.Modify();
    end;
}

