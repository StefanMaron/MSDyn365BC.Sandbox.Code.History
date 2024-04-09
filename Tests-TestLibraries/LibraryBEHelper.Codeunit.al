codeunit 143000 "Library - BE Helper"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        VatRegNoFormatNotFoundErr: Label 'VAT Registration Format not found.';
        LibrarySales: Codeunit "Library - Sales";
        LibraryResource: Codeunit "Library - Resource";
        LibraryService: Codeunit "Library - Service";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";

    [Scope('OnPrem')]
    procedure InitializeCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            if "E-Mail" = '' then begin
                "E-Mail" := 'test@test.tst'; // value not important, it must not be empty
                Modify();
            end;
            if "Enterprise No." = '' then begin
                "Enterprise No." := CreateMOD97CompliantCode();
                Modify();
            end;
            if "Country/Region Code" <> 'BE' then begin
                "Country/Region Code" := 'BE';
                Modify();
            end;
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateVATRegNoFormat(CountryCode: Code[10]; FormatText: Text[20])
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
    begin
        with VATRegistrationNoFormat do begin
            SetRange("Country/Region Code", CountryCode);
            if FindLast() then;
            "Country/Region Code" := CountryCode;
            "Line No." += 10000;
            Format := FormatText;
            Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure GetVATRegNoFormatText(): Text[20]
    begin
        exit('#########');
    end;

    [Scope('OnPrem')]
    procedure GetUniqueVATRegNo(CountryCode: Code[10]): Text[20]
    var
        TempVATEntry: Record "VAT Entry" temporary;
        VATRegistrationNo: Text[20];
    begin
        FillVATRegistrationNoBuffer(TempVATEntry);
        repeat
            VATRegistrationNo := LibraryERM.GenerateVATRegistrationNo(CountryCode);
            TempVATEntry.SetRange("VAT Registration No.", VATRegistrationNo);
        until TempVATEntry.IsEmpty();
        exit(VATRegistrationNo);
    end;

    local procedure FillVATRegistrationNoBuffer(var TempVATEntry: Record "VAT Entry" temporary)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        Customer.SetFilter("VAT Registration No.", '<>%1', '');
        if Customer.FindSet() then
            repeat
                TempVATEntry."Entry No." += 1;
                TempVATEntry."VAT Registration No." := Customer."VAT Registration No.";
                TempVATEntry.Insert();
            until Customer.Next() = 0;

        Vendor.SetFilter("VAT Registration No.", '<>%1', '');
        if Vendor.FindSet() then
            repeat
                TempVATEntry."Entry No." += 1;
                TempVATEntry."VAT Registration No." := Vendor."VAT Registration No.";
                TempVATEntry.Insert();
            until Vendor.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure CalcPercentage(Source: Decimal; Percentage: Integer; Precision: Decimal) Result: Decimal
    begin
        Result := Round(Source * (Percentage / 100), Precision);
    end;

    [Scope('OnPrem')]
    procedure CalcPercentageChange(Source: Decimal; Percentage: Integer; Precision: Decimal; Increase: Boolean) Result: Decimal
    begin
        if Increase then
            Result := Round(Source + (Source * (Percentage / 100)), Precision)
        else
            Result := Round(Source - (Source * (Percentage / 100)), Precision);
    end;

    local procedure ClearVATEntriesByEnterpriseNo(EnterpriseNo: Text)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Enterprise No.", EnterpriseNo);
        VATEntry.DeleteAll();
    end;

    [Scope('OnPrem')]
    procedure CreateEnterpriseNo(): Code[20]
    begin
        exit('TVA' + CreateMOD97CompliantCode());
    end;

    [Scope('OnPrem')]
    procedure CreateMOD97CompliantCode() CodeMod97Compliant: Code[10]
    var
        CompliantCodeBody: Integer;
    begin
        CompliantCodeBody := LibraryRandom.RandIntInRange(1, 100000000);
        CodeMod97Compliant := ConvertStr(Format(CompliantCodeBody, 8, '<Integer>'), ' ', '0');
        CodeMod97Compliant += ConvertStr(Format(97 - CompliantCodeBody mod 97, 2, '<Integer>'), ' ', '0');
    end;

    [Scope('OnPrem')]
    procedure CreateVatRegNo(CountryCode: Code[10]) Result: Text[20]
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
    begin
        VATRegistrationNoFormat.SetRange("Country/Region Code", CountryCode);
        if VATRegistrationNoFormat.FindFirst() then
            Result := VATRegistrationNoFormat.Format
        else
            Error(VatRegNoFormatNotFoundErr);
        Result := Format(LibraryRandom.RandIntInRange(100000000, 999999999));
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateCustomerItemSalesInvoiceAndPost(var Customer: Record Customer)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // Get a VATPostingGroup that dos not have 0% VAT.
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        CreateCustomerItemSalesInvoiceAndPostHelper(Customer, VATPostingSetup);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateVATPostingSetupCustomerItemSalesInvoiceAndPost(var Customer: Record Customer)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // Get a VATPostingGroup that dos not have 0% VAT.
        CreateVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreateCustomerItemSalesInvoiceAndPostHelper(Customer, VATPostingSetup);
    end;

    [Scope('OnPrem')]
    procedure CreateAndPostInvoiceInPeriod(CustomerNo: Code[20]; ItemNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocDate: Date;
    begin
        DocDate := CalcDate(
            '<+' + Format(LibraryRandom.RandInt(EndDate - StartDate)) + 'D>', StartDate);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        with SalesHeader do begin
            Validate("Order Date", DocDate);
            Validate("Posting Date", DocDate);
            Validate("Shipment Date", DocDate);
            Modify(true);
        end;
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, LibraryRandom.RandDec(10, 2));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    [Scope('OnPrem')]
    procedure CreateCustomer(var Customer: Record Customer; CountryCode: Code[10])
    begin
        LibrarySales.CreateCustomer(Customer);

        CreateVATRegNoFormat(CountryCode, GetVATRegNoFormatText());
        with Customer do begin
            "Country/Region Code" := CountryCode;
            if CountryCode <> 'BE' then
                Validate("VAT Registration No.", GetUniqueVATRegNo(CountryCode));
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateDomesticCustomer(var Customer: Record Customer)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CreateCustomer(Customer, CompanyInformation."Country/Region Code");
        with Customer do begin
            Validate("Enterprise No.", CreateEnterpriseNo());
            Modify();
        end;
        ClearVATEntriesByEnterpriseNo(Customer."Enterprise No.");
    end;

    [Scope('OnPrem')]
    procedure CreateDomesticCustomerWithVATSetup(var Customer: Record Customer; VATPostingSetup: Record "VAT Posting Setup")
    begin
        CreateDomesticCustomer(Customer);
        with Customer do begin
            "VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreateForeignCustomerWithVATSetup(var Customer: Record Customer; VATPostingSetup: Record "VAT Posting Setup")
    begin
        CreateCustomer(Customer, 'GB');
        with Customer do begin
            "VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            Modify();
        end;
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateItem(var Item: Record Item; VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Unit Price", LibraryRandom.RandInt(100));
        Item.Modify(true);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateResource(var Resource: Record Resource; VATPostingSetup: Record "VAT Posting Setup")
    var
        ResourceNo: Code[20];
    begin
        LibraryResource.CreateResource(Resource, VATPostingSetup."VAT Bus. Posting Group");
        ResourceNo := Resource."No.";

        Resource.SetFilter("No.", ResourceNo);
        Resource.FindFirst();
        with Resource do begin
            Validate("Unit Price", LibraryRandom.RandInt(100));
            Modify();
        end;
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateRepresentative(var Representative: Record Representative)
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion);
        with Representative do begin
            Init();
            Validate(ID, 'XX');  // Not important
            Name := 'X'; // Not important - but not Blank
            Address := 'X'; // Not important - but not Blank
            Validate("Country/Region Code", CountryRegion.Code);
            City := 'X'; // Not important - but not Blank
            "Post Code" := 'X'; // Not important - but not Blank
            Validate("E-Mail", 'test@test.tst');
            Phone := 'X'; // Not important - but not Blank
            Validate("Issued by", CountryRegion.Code);
            Validate("Identification Type", "Identification Type"::NVAT); // Not important
            Address := 'X'; // Not important - but not Blank
            Insert();
        end;
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region")
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion."EU Country/Region Code" := CountryRegion.Code;
        CountryRegion.Modify();
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateDomesticCustomerResourceServiceDocumentAndPost(var Customer: Record Customer; DocumentType: Enum "Service Document Type")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Resource: Record Resource;
        EndDate: Date;
        StartDate: Date;
    begin
        // Dates for posting
        StartDate := CalcDate('<+CY+1D>', WorkDate());
        EndDate := CalcDate('<+CY+1Y>', WorkDate());

        // Get a VATPostingGroup that dos not have 0% VAT.
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);

        // Create a Customer and assign the VATPostingGroup.
        CreateDomesticCustomerWithVATSetup(Customer, VATPostingSetup);

        // Create an Item and assign the VATPostingGroup.
        CreateResource(Resource, VATPostingSetup);

        // Create a ServiceInvoice for the created customer and item and post it to make sure VAT entries are created.
        CreateAndPostServiceDocumentInPeriod(Customer."No.", DocumentType, Resource."No.", StartDate, EndDate);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateForeignCustomerResourceServiceDocumentAndPost(var Customer: Record Customer; DocumentType: Enum "Service Document Type")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Resource: Record Resource;
        EndDate: Date;
        StartDate: Date;
    begin
        // Dates for posting
        StartDate := CalcDate('<+CY+1D>', WorkDate());
        EndDate := CalcDate('<+CY+1Y>', WorkDate());

        // Get a VATPostingGroup that dos not have 0% VAT.
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);

        // Create a Customer and assign the VATPostingGroup.
        CreateForeignCustomerWithVATSetup(Customer, VATPostingSetup);

        // Create an Item and assign the VATPostingGroup.
        CreateResource(Resource, VATPostingSetup);

        // Create a ServiceInvoice for the created customer and item and post it to make sure VAT entries are created.
        CreateAndPostServiceDocumentInPeriod(Customer."No.", DocumentType, Resource."No.", StartDate, EndDate);
    end;

    [Scope('OnPrem')]
    procedure CreateAndPostServiceDocumentInPeriod(CustomerNo: Code[20]; DocumentType: Enum "Service Document Type"; ResourceNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        DocDate: Date;
    begin
        DocDate := CalcDate(
            '<+' + Format(LibraryRandom.RandInt(EndDate - StartDate)) + 'D>', StartDate);
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        with ServiceHeader do begin
            Validate("Order Date", DocDate);
            Validate("Posting Date", DocDate);
            Modify(true);
        end;
        LibraryService.CreateServiceLine(
          ServiceLine, ServiceHeader, ServiceLine.Type::Resource, ResourceNo);
        ServiceLine.Validate(Quantity, 2);
        ServiceLine.Modify();

        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalculationType: Enum "Tax Calculation Type")
    var
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateGLAccount(GLAccount1);
        LibraryERM.CreateGLAccount(GLAccount2);
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type"::"Normal VAT";
        VATPostingSetup."VAT %" := LibraryRandom.RandInt(30);
        VATPostingSetup.Validate("Purchase VAT Account", GLAccount1."No.");
        VATPostingSetup.Validate("Purch. VAT Unreal. Account", GLAccount1."No.");
        VATPostingSetup.Validate("Sales VAT Account", GLAccount2."No.");
        VATPostingSetup.Validate("Sales VAT Unreal. Account", GLAccount2."No.");
        VATPostingSetup."Reverse Chrg. VAT Acc." := VATPostingSetup."Purchase VAT Account";
        VATPostingSetup."VAT Calculation Type" := VATCalculationType;
        VATPostingSetup.Modify();
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateGLAccount(var GLAccount: Record "G/L Account"; VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Enum "General Posting Type"; NonDeductibleVAT: Integer)
    var
        GLAccountNo: Code[20];
    begin
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GenPostingType);

        GLAccount.SetRange("No.", GLAccountNo);
        GLAccount.FindFirst();

        GLAccount."% Non deductible VAT" := NonDeductibleVAT;
        GLAccount.Modify();
    end;

    [Normal]
    [Scope('OnPrem')]
    procedure CreateCustomerItemSalesInvoiceAndPostHelper(var Customer: Record Customer; VATPostingSetup: Record "VAT Posting Setup")
    var
        Item: Record Item;
        EndDate: Date;
        StartDate: Date;
    begin
        // Dates for posting
        StartDate := CalcDate('<+CY+1D>', WorkDate());
        EndDate := CalcDate('<+CY+1Y>', WorkDate());

        // Create a Customer and assign the VATPostingGroup.
        CreateDomesticCustomerWithVATSetup(Customer, VATPostingSetup);

        // Create an Item and assign the VATPostingGroup.
        CreateItem(Item, VATPostingSetup);

        // Create a SalesInvoce for the created customer and item and post it to make sure VAT entries are created.
        CreateAndPostInvoiceInPeriod(Customer."No.", Item."No.", StartDate, EndDate);
    end;

    [Scope('OnPrem')]
    procedure CreatePaymentJournalTemplate(var PaymentJournalTemplate: Record "Payment Journal Template")
    begin
        with PaymentJournalTemplate do begin
            Init();
            Name := LibraryUtility.GenerateRandomCode(FieldNo(Name), DATABASE::"Payment Journal Template");
            Insert();
        end;
    end;

    [Scope('OnPrem')]
    procedure CreatePaymentJournalBatch(var PaymJournalBatch: Record "Paym. Journal Batch"; PaymentJournalTemplateName: Code[10])
    begin
        with PaymJournalBatch do begin
            Init();
            "Journal Template Name" := PaymentJournalTemplateName;
            Name := LibraryUtility.GenerateRandomCode(FieldNo(Name), DATABASE::"Paym. Journal Batch");
            Insert();
        end;
    end;
}

