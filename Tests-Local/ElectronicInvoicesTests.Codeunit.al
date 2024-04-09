#if not CLEAN24
codeunit 141001 "Electronic Invoices - Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    ObsoleteReason = 'Moved to IS Core App.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    trigger OnRun()
    begin
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInvt: Codeunit "Library - Inventory";
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Initialized: Boolean;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        Initialized := true;
        LibrarySales.SetStockoutWarning(false);
        LibrarySales.SetCreditWarningsToNoWarnings;
        Commit();
    end;

    [Test]
    [HandlerFunctions('MsgHandler')]
    [Scope('OnPrem')]
    procedure SalesSetup_ElectronicInvoicing()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        IsElectronicInvoicing: Boolean;
    begin
        Initialize();

        for IsElectronicInvoicing := false to true do begin
            // Exercise
            SetElectronicInvoicing(IsElectronicInvoicing);

            // Verify
            SalesSetup.Get();
            Assert.AreEqual(IsElectronicInvoicing, SalesSetup."Electronic Invoicing", '');
        end;
    end;

    [Test]
    [HandlerFunctions('MsgHandler,SalesQuoteRequestHandler')]
    [Scope('OnPrem')]
    procedure SalesQuote_ElectronicInvoicing()
    var
        SalesHeader: Record "Sales Header";
        IsElectronicInvoicing: Boolean;
    begin
        Initialize();

        CreateSalesDoc(SalesHeader, SalesHeader."Document Type"::Quote);

        for IsElectronicInvoicing := false to true do begin
            // Exercise
            SetElectronicInvoicing(IsElectronicInvoicing);
            REPORT.Run(REPORT::"Standard Sales - Quote", true, false, SalesHeader);

            // Verify
            asserterror VerifyElectronicInvInDataset(IsElectronicInvoicing);
            Assert.ExpectedError('ElectronicInvoicing');
        end;
    end;

    local procedure VerifyElectronicInvInDataset(IsOn: Boolean)
    begin
        with LibraryReportDataset do begin
            LoadDataSetFile;
            Reset();
            SetRange('ElectronicInvoicing', IsOn);
            Assert.IsTrue(GetNextRow, '');
        end;
    end;

    local procedure CreateSalesDoc(var SalesHeader: Record "Sales Header"; DocType: Option)
    var
        SalesLine: Record "Sales Line";
        Cust: Record Customer;
        Item: Record Item;
    begin
        LibrarySales.CreateCustomer(Cust);
        LibrarySales.CreateSalesHeader(SalesHeader, DocType, Cust."No.");
        LibraryInvt.CreateItem(Item);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        Commit();
    end;

    local procedure CreateSalesInvAndPost(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDoc(SalesHeader, SalesHeader."Document Type"::Invoice);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateSalesCrMemoAndPost(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDoc(SalesHeader, SalesHeader."Document Type"::"Credit Memo");
        SalesCrMemoHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure SetElectronicInvoicing(Value: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup.Validate("Electronic Invoicing", Value);
        SalesSetup.Modify();
        Commit();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesQuoteRequestHandler(var SalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
        SalesQuote.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MsgHandler(MsgTxt: Text)
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(QuestionTxt: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;
}
#endif
