﻿codeunit 101009 "Create Country/Region"
{

    trigger OnRun()
    begin
        // The Intrastat Code is a 2 character code in GB and a
        InsertData('AT', XAustria, '040', 'AT', 'AT', 3, 1, '0007', '');
        InsertVATRegNoFormat('AT', 10000, 'ATU########');
        InsertData('AU', XAustralia, '036', '', '', 2, 1, '', '');
        InsertData('BE', XBelgium, '056', 'BE', 'BE', 0, 1, '9925', '');
        InsertVATRegNoFormat('BE', 10000, 'BE#########');
        InsertVATRegNoFormat('BE', 20000, 'BE #########');
        InsertVATRegNoFormat('BE', 30000, 'BE ###.###.###');
        InsertVATRegNoFormat('BE', 40000, 'BE ### ### ###');
        InsertVATRegNoFormat('BE', 50000, '#########');
        InsertVATRegNoFormat('BE', 60000, '###.###.###');
        InsertVATRegNoFormat('BE', 70000, '### ### ###');
        InsertData('BG', XBulgaria, '100', 'BG', 'BG', 2, 1, '9926', '');
        InsertVATRegNoFormat('BG', 10000, 'BG##########');
        InsertVATRegNoFormat('BG', 20000, 'BG#########');
        InsertData('BR', XBrazil, '076', '', '', 1, 0, '', '');
        InsertData('CA', XCanada, '124', '', '', 2, 1, '', XProvince);
        InsertData('CH', XSwitzerland, '756', '', '', 0, 1, '', '');
        InsertVATRegNoFormat('CH', 10000, 'CHE-###.###.###MWST');
        InsertVATRegNoFormat('CH', 20000, 'CHE-###.###.### TVA');
        InsertVATRegNoFormat('CH', 30000, 'CHE-###.###.### IVA');
        InsertVATRegNoFormat('CH', 40000, '### ###');
        InsertData('CZ', XCzechia, '203', 'CZ', 'CZ', 0, 1, '9929', '');
        InsertVATRegNoFormat('CZ', 10000, 'CZ########');
        InsertVATRegNoFormat('CZ', 20000, 'CZ#########');
        InsertVATRegNoFormat('CZ', 30000, 'CZ##########');
        InsertVATRegNoFormat('CZ', 40000, '########');
        InsertVATRegNoFormat('CZ', 50000, '#########');
        InsertVATRegNoFormat('CZ', 60000, '##########');
        InsertData('DE', XGermany, '276', 'DE', 'DE', 3, 1, '9930', '');
        InsertVATRegNoFormat('DE', 10000, 'DE#########');
        InsertVATRegNoFormat('DE', 20000, '#########');
        InsertData('DK', XDenmark, '208', 'DK', 'DK', 0, 1, '0190', '');
        InsertVATRegNoFormat('DK', 10000, 'DK########');
        InsertVATRegNoFormat('DK', 20000, '########');
        InsertData('ES', XSpain, '724', 'ES', 'ES', 0, 1, '9920', '');
        InsertVATRegNoFormat('ES', 10000, 'ES########@');
        InsertVATRegNoFormat('ES', 20000, '########@');
        InsertVATRegNoFormat('ES', 30000, 'ES@########');
        InsertVATRegNoFormat('ES', 40000, '@########');
        InsertVATRegNoFormat('ES', 50000, 'ES@#######@');
        InsertVATRegNoFormat('ES', 60000, '@#######@');
        InsertVATRegNoFormat('ES', 70000, '@########@');
        InsertVATRegNoFormat('ES', 80000, '@######@');
        InsertVATRegNoFormat('ES', 90000, '@#####@');
        InsertVATRegNoFormat('ES', 100000, '#######@');
        InsertVATRegNoFormat('ES', 110000, '######@');
        InsertVATRegNoFormat('ES', 120000, '#####@');
        InsertVATRegNoFormat('ES', 130000, '@#######');
        InsertVATRegNoFormat('ES', 140000, '@######');
        InsertVATRegNoFormat('ES', 150000, '@#####');
        InsertData('EE', XEstonia, '233', 'EE', 'EE', 0, 1, '9931', '');
        InsertVATRegNoFormat('EE', 10000, 'EE#########');
        InsertVATRegNoFormat('EE', 20000, '#########');
        InsertData('FR', XFrance, '250', 'FR', 'FR', 0, 1, '0009', '');
        InsertVATRegNoFormat('FR', 10000, 'FR###########');
        InsertVATRegNoFormat('FR', 20000, '###########');
        InsertData('GB', XGreatBritain, '826', '', 'GB', 2, 1, '9932', '');
        InsertVATRegNoFormat('GB', 10000, 'GB#########');
        InsertVATRegNoFormat('GB', 20000, 'GB###-####-##');
        InsertVATRegNoFormat('GB', 30000, 'GB### #### ##');
        InsertVATRegNoFormat('GB', 40000, '###-####-##');
        InsertVATRegNoFormat('GB', 50000, '### #### ##');
        InsertVATRegNoFormat('GB', 60000, '#########');
        InsertData('ID', XIndonesia, '360', '', '', 0, 1, '', '');
        InsertData('IN', XIndia, '356', '', '', 1, 0, '', '');
        InsertData('IS', XIceland, '352', '', '', 0, 1, '', '');
        InsertData('IT', XItaly, '380', 'IT', 'IT', 0, 1, '0097', '');
        InsertData('LU', XLuxembourg, '442', 'LU', 'LU', 0, 1, '9938', '');
        InsertVATRegNoFormat('LU', 10000, 'LU########');
        InsertVATRegNoFormat('LU', 20000, '########');
        InsertData('LT', XLithuania, '440', 'LT', 'LT', 0, 1, '0200', '');
        InsertVATRegNoFormat('LT', 10000, 'LT#########');
        InsertVATRegNoFormat('LT', 20000, 'LT############');
        InsertVATRegNoFormat('LT', 30000, '#########');
        InsertVATRegNoFormat('LT', 40000, '############');
        InsertData('LV', XLatvia, '428', 'LV', 'LV', 0, 1, '9939', '');
        InsertVATRegNoFormat('LV', 10000, 'LV###########');
        InsertVATRegNoFormat('LV', 20000, '###########');
        InsertData('MY', XMalaysia, '458', '', '', 0, 1, '', '');
        InsertData('MX', XMexico, '484', '', '', 2, 1, '', '');
        InsertDataExtended('NI', XNothernIreland, 'GB', '826', 'GBN', 'GBN', 2, 1, '9932', '');
        InsertData('NL', XNetherlands, '528', 'NL', 'NL', 0, 1, '9944', '');
        InsertVATRegNoFormat('NL', 10000, 'NL#########B##');
        InsertVATRegNoFormat('NL', 20000, '#########B##');
        InsertData('NO', XNorway, '578', '', '', 0, 1, '0192', '');
        InsertVATRegNoFormat('NO', 10000, 'NO ### ### ### MVA');
        InsertVATRegNoFormat('NO', 20000, '### ### ### MVA');
        InsertVATRegNoFormat('NO', 30000, 'NO ### ### ###');
        InsertVATRegNoFormat('NO', 40000, '#########');
        InsertData('NZ', XNewZealand, '554', '', '', 1, 1, '', '');
        InsertData('PL', XPoland, '616', 'PL', 'PL', 0, 1, '9945', '');
        InsertVATRegNoFormat('PL', 10000, 'PL##########');
        InsertVATRegNoFormat('PL', 20000, '##########');
        InsertData('PT', XPortugal, '620', 'PT', 'PT', 0, 1, '9946', '');
        InsertData('RU', XRussia, '643', '', '', 1, 2, '', XRegion);
        InsertData('SG', XSingapore, '702', '', '', 1, 1, '', '');
        InsertVATRegNoFormat('SG', 10000, '##-#######-?');
        InsertData('SE', XSweden, '752', 'SE', 'SE', 0, 1, '9955', '');
        InsertVATRegNoFormat('SE', 10000, 'SE##########01');
        InsertVATRegNoFormat('SE', 20000, '##########01');
        InsertData('SI', XSlovenia, '705', 'SI', 'SI', 0, 1, '9949', '');
        InsertVATRegNoFormat('SI', 10000, 'SI########');
        InsertVATRegNoFormat('SI', 20000, '########');
        InsertData('TH', XThailand, '764', '', '', 0, 1, '', '');
        InsertData('TR', XTurkey, '792', '', '', 0, 0, '9952', '');
        InsertData('US', XUSA, '840', '', '', 2, 1, '', XState);
        InsertData('ZA', XSouthAfrica, '710', '', '', 1, 0, '', '');
        InsertData('MA', XMorocco, '504', '', '', 0, 1, '', '');
        InsertData('DZ', XAlgeria, '012', '', '', 0, 1, '', '');
        InsertData('TN', XTunisia, '788', '', '', 0, 1, '', '');
        InsertData('KE', XKenya, '404', '', '', 0, 1, '', '');
        InsertData('UG', XUganda, '800', '', '', 1, 1, '', '');
        InsertData('AE', XUnitedArabEmirates, '784', '', '', 1, 1, '', '');
        InsertData('MZ', XMozambique, '508', '', '', 0, 1, '', '');
        InsertData('SZ', XSwaziland, '748', '', '', 1, 1, '', '');
        InsertData('FI', XFinland, '246', 'FI', 'FI', 0, 1, '', '');
        InsertData('HU', XHungary, '348', 'HU', 'HU', 1, 1, '9910', '');
        InsertVATRegNoFormat('HU', 10000, 'HU########');
        InsertVATRegNoFormat('HU', 20000, '########');
        InsertData('RO', XRomania, '642', 'RO', 'RO', 0, 1, '9947', '');
        InsertVATRegNoFormat('RO', 10000, 'RO##########');
        InsertData('EL', XGreece, '300', 'EL', 'EL', 0, 1, '', '');
        InsertData('IE', XIreland, '372', 'IE', 'IE', 2, 1, '9935', '');
        InsertData('NG', XNigeria, '566', '', '', 1, 1, '', '');
        InsertData('PH', XPhilippines, '608', '', '', 0, 1, '', '');
        InsertData('TZ', XTanzania, '834', '', '', 0, 1, '', '');
        InsertData('HR', XCroatia, '191', 'HR', 'HR', 0, 1, '9934', '');
        InsertVATRegNoFormat('HR', 10000, 'HR###########');
        InsertData('CY', XCyprus, '196', 'CY', 'CY', 0, 1, '9928', '');
        InsertVATRegNoFormat('CY', 10000, 'CY########@');
        InsertVATRegNoFormat('CY', 20000, '########@');
        InsertData('MT', XMalta, '470', 'MT', 'MT', 0, 1, '9943', '');
        InsertVATRegNoFormat('MT', 10000, 'MT########');
        InsertVATRegNoFormat('MT', 20000, '########');
        InsertData('SK', XSlovakia, '703', 'SK', 'SK', 0, 1, '9950', '');
        InsertVATRegNoFormat('SK', 10000, 'SK#########');
        InsertVATRegNoFormat('SK', 20000, 'SK##########');
        InsertVATRegNoFormat('SK', 30000, '#########');
        InsertVATRegNoFormat('SK', 40000, '##########');
        InsertData('BN', XBruneiDarussalam, '096', '', '', 1, 0, '', '');
        InsertData('FJ', XFijiIslands, '242', '', '', 1, 0, '', '');
        InsertData('JP', XJapan, '392', '', '', 1, 0, '', '');
        InsertData('SA', XSaudiArabia, '682', '', '', 1, 0, '', '');
        InsertData('SB', XSolomonIslands, '090', '', '', 1, 0, '', '');
        InsertData('VU', XVanuatu, '548', '', '', 1, 0, '', '');
        InsertData('WS', XSamoa, '882', '', '', 1, 0, '', '');
        InsertData('RS', XSerbia, '688', '', '', 0, 1, '9948', '');
        InsertData('ME', XMontenegro, '499', '', '', 0, 1, '9941', '');
        InsertData('CN', XChinaTxt, '156', '', '', 0, 0, '', '');
        InsertData('CR', XCostaRica, '188', '', '', 0, 0, '', '');
    end;

    var
        Country: Record "Country/Region";
        VATRegNoFormat: Record "VAT Registration No. Format";
        XAustria: Label 'Austria';
        XAustralia: Label 'Australia';
        XBelgium: Label 'Belgium';
        XBulgaria: Label 'Bulgaria';
        XBrazil: Label 'Brazil';
        XCanada: Label 'Canada';
        XChinaTxt: Label 'China';
        XCroatia: Label 'Croatia';
        XCyprus: Label 'Cyprus';
        XSwitzerland: Label 'Switzerland';
        XMontenegro: Label 'Montenegro';
        XSerbia: Label 'Serbia';
        XCzechia: Label 'Czechia';
        XGermany: Label 'Germany';
        XDenmark: Label 'Denmark';
        XSpain: Label 'Spain';
        XEstonia: Label 'Estonia';
        XFrance: Label 'France';
        XGreatBritain: Label 'Great Britain';
        XIndonesia: Label 'Indonesia';
        XIndia: Label 'India';
        XIceland: Label 'Iceland';
        XItaly: Label 'Italy';
        XLuxembourg: Label 'Luxembourg';
        XLithuania: Label 'Lithuania';
        XLatvia: Label 'Latvia';
        XMalaysia: Label 'Malaysia';
        XMexico: Label 'Mexico';
        XNetherlands: Label 'Netherlands';
        XNorway: Label 'Norway';
        XNewZealand: Label 'New Zealand';
        XPoland: Label 'Poland';
        XPortugal: Label 'Portugal';
        XRussia: Label 'Russia';
        XSingapore: Label 'Singapore';
        XSweden: Label 'Sweden';
        XSlovenia: Label 'Slovenia';
        XThailand: Label 'Thailand';
        XTurkey: Label 'Türkiye';
        XUSA: Label 'USA';
        XSouthAfrica: Label 'South Africa';
        XMorocco: Label 'Morocco';
        XAlgeria: Label 'Algeria';
        XTunisia: Label 'Tunisia';
        XKenya: Label 'Kenya';
        XUganda: Label 'Uganda';
        XUnitedArabEmirates: Label 'United Arab Emirates';
        XMozambique: Label 'Mozambique';
        XSwaziland: Label 'Swaziland';
        XFinland: Label 'Finland';
        XHungary: Label 'Hungary';
        XRomania: Label 'Romania';
        XGreece: Label 'Greece';
        XIreland: Label 'Ireland';
        XNigeria: Label 'Nigeria';
        XPhilippines: Label 'Philippines';
        XTanzania: Label 'Tanzania';
        XMalta: Label 'Malta';
        XSlovakia: Label 'Slovakia';
        XBruneiDarussalam: Label 'Brunei Darussalam';
        XFijiIslands: Label 'Fiji Islands';
        XJapan: Label 'Japan';
        XSaudiArabia: Label 'Saudi Arabia';
        XSolomonIslands: Label 'Solomon Islands';
        XVanuatu: Label 'Vanuatu';
        XSamoa: Label 'Samoa';
        XCostaRica: Label 'Costa Rica';
        XProvince: Label 'Province';
        XState: Label 'State';
        XRegion: Label 'Region';
        XNothernIreland: Label 'Nothern Ireland';

    procedure InsertData("Code": Code[10]; Name: Text[50]; ISONumericCode: Code[3]; "EU Country Code": Code[10]; "Intrastat Code": Code[10]; "Address Format": Option; "Contact Address Format": Option; VATScheme: Code[10]; CountyName: Text[30])
    begin
        InsertDataExtended(
          Code, Name, CopyStr(Code, 1, 2), ISONumericCode, "EU Country Code",
          "Intrastat Code", "Address Format", "Contact Address Format", VATScheme, CountyName);
    end;

    procedure InsertDataExtended("Code": Code[10]; Name: Text[50]; ISOCode: Code[2]; ISONumericCode: Code[3]; "EU Country Code": Code[10]; "Intrastat Code": Code[10]; "Address Format": Option; "Contact Address Format": Option; VATScheme: Code[10]; CountyName: Text[30])
    begin
        Country.Init();
        Country.Validate(Code, Code);
        Country.Validate("ISO Code", ISOCode);
        Country.Validate("ISO Numeric Code", ISONumericCode);
        Country.Validate(Name, Name);
        Country.Validate("EU Country/Region Code", "EU Country Code");
        Country.Validate("Intrastat Code", "Intrastat Code");
        Country.Validate("Address Format", "Address Format");
        Country.Validate("Contact Address Format", "Contact Address Format");
        Country.Validate("VAT Scheme", VATScheme);
        Country.Validate("County Name", CountyName);
        Country.Insert(true);
    end;

    procedure InsertVATRegNoFormat("Country Code": Code[10]; "Line No.": Integer; Format: Text[20])
    begin
        VATRegNoFormat.Init();
        VATRegNoFormat.Validate("Country/Region Code", "Country Code");
        VATRegNoFormat.Validate("Line No.", "Line No.");
        VATRegNoFormat.Validate(Format, Format);
        VATRegNoFormat.Insert(true);
    end;

    procedure UpdateIBANCountries()
    begin
        with Country do begin
            Reset();
            if Find('-') then
                repeat
                    case Code of
                        'BE', 'DE', 'FR', 'IT', 'AT', 'DK', 'EL', 'LU', 'PT', 'GB', 'FI', 'IE', 'NL', 'ES', 'SE':
                            begin
                                "IBAN Country/Region" := true;
                                Modify();
                            end;
                    end;
                until Next = 0;
        end;
    end;
}

