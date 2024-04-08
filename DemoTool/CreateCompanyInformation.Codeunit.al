codeunit 101079 "Create Company Information"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        InsertData;
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CompanyInformation: Record "Company Information";
        XCRONUSInternationalLtd: Label 'CRONUS International Ltd.';
        X5TheRing: Label '5 The Ring';
        XWestminster: Label 'Westminster';
        X06666666666: Label '0666-666-6666';
        X06666666660: Label '0666-666-6660';
        X8889999: Label '888-9999';
        XWorldWideBank: Label 'World Wide Bank';
        XBG99999: Label 'BG99999';
        X9999888: Label '99-99-888';
        XGB12CPBK08929965044991: Label 'GB 12 CPBK 08929965044991';
        X9999999: Label '99-99-999';
        XContactNameTxt: Label 'Adam Matteson';
        XCRONUSEspanaSA: Label 'CRONUS España S.A.';
        XAvenidaAragon5: Label 'Avenida Aragón, 5';
        XCentroNegocios: Label 'Centro Negocios';
        XDistribucionmuebles: Label 'Distribución muebles';
        X912229788: Label '91-2229788';
        X912229700: Label '91-2229700';

    procedure InsertData()
    var
        CreatePostCode: Codeunit "Create Post Code";
    begin
        if CompanyInformation.Get() then
            CompanyInformation.Delete();

        CompanyInformation.Init();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Validate("Primary Key", '');
        CompanyInformation.Validate(Name, XCRONUSEspanaSA);
        CompanyInformation.Validate(Address, XAvenidaAragon5);
        CompanyInformation.Validate("Address 2", XCentroNegocios);
        CompanyInformation.Validate("Country/Region Code", DemoDataSetup."Country/Region Code");
        CompanyInformation."Post Code" := CreatePostCode.FindPostCode(CreatePostCode.Convert('GB-W2 8HG'));
        CompanyInformation.City := CreatePostCode.FindCity(CompanyInformation."Post Code");
        CompanyInformation.County := CreatePostCode.FindCounty(CompanyInformation."Post Code");
        CompanyInformation.Validate("Contact Person", XContactNameTxt);
        CompanyInformation.Validate("Phone No.", X912229788);
        CompanyInformation.Validate("Fax No.", X912229700);
        CompanyInformation.Validate("CCC Bank No.", '1111');
        CompanyInformation.Validate("CCC Bank Branch No.", '2222');
        CompanyInformation.Validate("CCC Control Digits", '33');
        CompanyInformation.Validate("CCC Bank Account No.", '1234567890');
        CompanyInformation.Validate("CNAE Description", XDistribucionmuebles);
        CompanyInformation."System Indicator Style" := CompanyInformation."System Indicator Style"::Standard;
        CompanyInformation."System Indicator" := CompanyInformation."System Indicator"::None;
        CompanyInformation."VAT Registration No." := '77777777A';

        CompanyInformation.Validate("Ship-to Name", XCRONUSEspanaSA);
        CompanyInformation.Validate("Ship-to Address", XAvenidaAragon5);
        CompanyInformation.Validate("Ship-to Address 2", XCentroNegocios);
        CompanyInformation.Validate("Ship-to Country/Region Code", DemoDataSetup."Country/Region Code");
        CompanyInformation."Ship-to Post Code" := CreatePostCode.FindPostCode(CreatePostCode.Convert('GB-W2 8HG'));
        CompanyInformation."Ship-to City" := CreatePostCode.FindCity(CompanyInformation."Ship-to Post Code");
        CompanyInformation.Picture.Import(DemoDataSetup."Path to Picture Folder" + 'cronus.jpg');

        CompanyInformation.Insert();
    end;
}

