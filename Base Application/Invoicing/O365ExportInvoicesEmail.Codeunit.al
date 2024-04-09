#if not CLEAN21
codeunit 2129 "O365 Export Invoices + Email"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
    end;

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        NoInvoicesExportedErr: Label 'There were no invoices to export.';
        InvoicesExportedMsg: Label 'Your exported invoices have been sent.';
        AttachmentNameTxt: Label 'Invoices.xlsx';
        ExportInvoicesEmailSubjectTxt: Label 'Please find the invoices summary and price details from %1 date until %2 date in the attached Excel book.', Comment = '%1 = Start Date, %2 =End Date';
        InvoiceNoFieldTxt: Label 'Invoice No.';
        CustomerNameFieldTxt: Label 'Customer Name';
        AddressFieldTxt: Label 'Address';
        CityFieldTxt: Label 'City';
        CountyFieldTxt: Label 'County';
        CountryRegionCodeFieldTxt: Label 'Country/Region Code';
        InvoiceDateFieldTxt: Label 'Invoice Date';
        NetTotalFieldTxt: Label 'Net Total';
        TotalIncludingVatFieldTxt: Label 'Total Including VAT';
        VatPercentFieldTxt: Label 'VAT %', Comment = 'The heading used when exporting the invoice lines';
        InvoicesSummaryHeaderTxt: Label 'Invoices Summary';
        ItemsHeaderTxt: Label 'Prices';
        InvoicesSheetNameTxt: Label 'Invoices';
        CompanyInformation: Record "Company Information";
        CellBold: Boolean;
        RowNo: Integer;
        LineRowNo: Integer;
        InvoiceStatusTxt: Label 'Status';
        ExportInvoicesCategoryLbl: Label 'AL Export Invoices', Locked = true;
        ExportInvoicesFailedNoInvoicesTxt: Label 'Export Invoices failed, there are no invoices.', Locked = true;
        ExportInvoicesSuccessTxt: Label 'Export Invoices succeeded.', Locked = true;
        ExportInvoicesFailedSendingTxt: Label 'Export Invoices failed sending.', Locked = true;
        GSTAmountTxt: Label 'GST Amount';
        PSTAmountTxt: Label 'PST Amount';
        HSTAmountTxt: Label 'HST Amount';

    [Scope('OnPrem')]
    procedure ExportInvoicesToExcelandEmail(StartDate: Date; EndDate: Date; Email: Text[80])
    var
        TempEmailItem: Record "Email Item" temporary;
        EmailSuccess: Boolean;
        ServerFileName: Text;
        File: File;
        Instream: Instream;
    begin
        SalesInvoiceHeader.SetRange("Document Date", StartDate, EndDate);

        if not SalesInvoiceHeader.FindSet() then begin
            Session.LogMessage('000023Z', ExportInvoicesFailedNoInvoicesTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ExportInvoicesCategoryLbl);
            Error(NoInvoicesExportedErr);
        end;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        ServerFileName := ExportInvoicesToExcel(StartDate, EndDate);

        TempExcelBuffer.CreateBook(ServerFileName, InvoicesSheetNameTxt);
        TempExcelBuffer.WriteSheet(InvoicesSheetNameTxt, CompanyName, UserId);
        TempExcelBuffer.CloseBook();

        Codeunit.Run(Codeunit::"O365 Setup Email");

        TempEmailItem.Validate("Send to", Email);
        TempEmailItem.Validate(Subject, StrSubstNo(ExportInvoicesEmailSubjectTxt, StartDate, EndDate));
        File.Open(ServerFileName);
        File.CreateInStream(InStream);
        TempEmailItem.AddAttachment(InStream, AttachmentNameTxt);
        File.Close();
        EmailSuccess := TempEmailItem.Send(true);

        if EmailSuccess then begin
            Session.LogMessage('0000240', ExportInvoicesSuccessTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ExportInvoicesCategoryLbl);
            Message(InvoicesExportedMsg);
        end else
            Session.LogMessage('0000241', ExportInvoicesFailedSendingTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ExportInvoicesCategoryLbl);
    end;

    [Scope('OnPrem')]
    procedure ExportInvoicesToExcel(StartDate: Date; EndDate: Date) ServerFileName: Text
    var
        FileManagement: Codeunit "File Management";
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        SalesInvoiceHeader.SetRange("Document Date", StartDate, EndDate);

        if not SalesInvoiceHeader.FindSet() then
            Error(NoInvoicesExportedErr);

        TempExcelBuffer.Reset();
        InsertHeaderTextForSalesInvoices();
        InsertHeaderTextForSalesLines();
        InsertSalesInvoices();

        ServerFileName := FileManagement.ServerTempFileName('xlsx');
        TempExcelBuffer.CreateBook(ServerFileName, InvoicesSheetNameTxt);
        TempExcelBuffer.WriteSheet(InvoicesSheetNameTxt, CompanyName, UserId);
        TempExcelBuffer.CloseBook();
    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Variant)
    begin
        TempExcelBuffer.EnterCell(TempExcelBuffer, RowNo, ColumnNo, CellValue, CellBold, false, false);
    end;

    local procedure InsertSalesInvoiceSummary()
    var
        TempSalesTaxAmountLine: Record "Sales Tax Amount Line" temporary;
        ColNo: Integer;
    begin
        EnterCell(RowNo, 1, SalesInvoiceHeader."No.");
        EnterCell(RowNo, 2, SalesInvoiceHeader."Sell-to Customer Name");
        EnterCell(RowNo, 3, SalesInvoiceHeader."Sell-to Address");
        EnterCell(RowNo, 4, SalesInvoiceHeader."Sell-to City");
        EnterCell(RowNo, 5, SalesInvoiceHeader."Sell-to County");
        EnterCell(RowNo, 6, SalesInvoiceHeader."Sell-to Country/Region Code");
        EnterCell(RowNo, 7, SalesInvoiceHeader."Document Date");
        EnterCell(RowNo, 8, SalesInvoiceHeader."Due Date");
        EnterCell(RowNo, 9, SalesInvoiceHeader."Tax Liable");
        EnterCell(RowNo, 10, SalesInvoiceHeader.GetWorkDescription());
        EnterCell(RowNo, 11, SalesInvoiceHeader.Amount);
        EnterCell(RowNo, 12, SalesInvoiceHeader."Amount Including VAT");
        EnterCell(RowNo, 13, SalesInvoiceHeader."Invoice Discount Amount");

        if CompanyInformation.IsCanada() then begin
            GetTaxSummarizedLines(TempSalesTaxAmountLine);
            if TempSalesTaxAmountLine.FindSet() then
                repeat
                    case TempSalesTaxAmountLine."Print Description" of
                        'GST':
                            EnterCell(RowNo, 14, TempSalesTaxAmountLine."Tax Amount");
                        'PST', 'QST':
                            EnterCell(RowNo, 15, TempSalesTaxAmountLine."Tax Amount");
                        'HST':
                            EnterCell(RowNo, 16, TempSalesTaxAmountLine."Tax Amount");
                    end;
                until TempSalesTaxAmountLine.Next() = 0;
        end;

        if CompanyInformation.IsCanada() then
            ColNo := 17
        else
            ColNo := 14;

        EnterCell(RowNo, ColNo, GetDocumentStatus(SalesInvoiceHeader));
    end;

    local procedure InsertSalesLineItem()
    begin
        EnterCell(LineRowNo, 1, SalesInvoiceLine."Document No.");
        EnterCell(LineRowNo, 2, SalesInvoiceHeader."Sell-to Customer Name");
        EnterCell(LineRowNo, 3, SalesInvoiceLine.Description);
        EnterCell(LineRowNo, 4, SalesInvoiceLine.Quantity);
        EnterCell(LineRowNo, 5, SalesInvoiceLine."Unit of Measure");
        EnterCell(LineRowNo, 6, SalesInvoiceLine."Unit Price");
        EnterCell(LineRowNo, 7, SalesInvoiceLine."Tax Group Code");
        EnterCell(LineRowNo, 8, SalesInvoiceLine."VAT %");
        EnterCell(LineRowNo, 9, SalesInvoiceLine.Amount);
        EnterCell(LineRowNo, 10, SalesInvoiceLine."Amount Including VAT");
        EnterCell(LineRowNo, 11, SalesInvoiceLine."Line Discount Amount");
    end;

    local procedure InsertHeaderTextForSalesInvoices()
    begin
        CellBold := true;
        RowNo := 1;
        EnterCell(RowNo, 1, InvoicesSummaryHeaderTxt);

        RowNo := RowNo + 1;
        EnterCell(RowNo, 1, InvoiceNoFieldTxt);
        EnterCell(RowNo, 2, CustomerNameFieldTxt);
        EnterCell(RowNo, 3, AddressFieldTxt);
        EnterCell(RowNo, 4, CityFieldTxt);
        EnterCell(RowNo, 5, CountyFieldTxt);
        EnterCell(RowNo, 6, CountryRegionCodeFieldTxt);
        EnterCell(RowNo, 7, InvoiceDateFieldTxt);
        EnterCell(RowNo, 8, SalesInvoiceHeader.FieldCaption("Due Date"));
        EnterCell(RowNo, 9, SalesInvoiceHeader.FieldCaption("Tax Liable"));
        EnterCell(RowNo, 10, SalesInvoiceHeader.FieldCaption("Work Description"));
        EnterCell(RowNo, 11, NetTotalFieldTxt);
        EnterCell(RowNo, 12, TotalIncludingVatFieldTxt);
        EnterCell(RowNo, 13, SalesInvoiceHeader.FieldCaption("Invoice Discount Amount"));
        if CompanyInformation.IsCanada() then begin
            EnterCell(RowNo, 14, GSTAmountTxt);
            EnterCell(RowNo, 15, PSTAmountTxt);
            EnterCell(RowNo, 16, HSTAmountTxt);
            EnterCell(RowNo, 17, InvoiceStatusTxt);
        end else
            EnterCell(RowNo, 14, InvoiceStatusTxt);

        CellBold := false;
    end;

    local procedure InsertHeaderTextForSalesLines()
    var
        NumberOfEmptyLines: Integer;
    begin
        CellBold := true;
        NumberOfEmptyLines := 5;
        LineRowNo := SalesInvoiceHeader.Count + NumberOfEmptyLines;
        EnterCell(LineRowNo, 1, ItemsHeaderTxt);

        LineRowNo := LineRowNo + 1;
        EnterCell(LineRowNo, 1, InvoiceNoFieldTxt);
        EnterCell(LineRowNo, 2, CustomerNameFieldTxt);
        EnterCell(LineRowNo, 3, SalesInvoiceLine.FieldCaption(Description));
        EnterCell(LineRowNo, 4, SalesInvoiceLine.FieldCaption(Quantity));
        EnterCell(LineRowNo, 5, SalesInvoiceLine.FieldCaption("Unit of Measure"));
        EnterCell(LineRowNo, 6, SalesInvoiceLine.FieldCaption("Unit Price"));
        EnterCell(LineRowNo, 7, SalesInvoiceLine.FieldCaption("Tax Group Code"));
        EnterCell(LineRowNo, 8, VatPercentFieldTxt);
        EnterCell(LineRowNo, 9, SalesInvoiceLine.FieldCaption(Amount));
        EnterCell(LineRowNo, 10, SalesInvoiceLine.FieldCaption("Amount Including VAT"));
        EnterCell(LineRowNo, 11, SalesInvoiceLine.FieldCaption("Line Discount Amount"));
        CellBold := false;
    end;

    local procedure InsertSalesInvoices()
    begin
        if SalesInvoiceHeader.FindSet() then
            repeat
                RowNo := RowNo + 1;
                SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Work Description", "Invoice Discount Amount");
                InsertSalesInvoiceSummary();
                SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                if SalesInvoiceLine.FindSet() then
                    repeat
                        LineRowNo := LineRowNo + 1;
                        InsertSalesLineItem();
                    until SalesInvoiceLine.Next() = 0;
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure GetDocumentStatus(SalesInvoiceHeader: Record "Sales Invoice Header") Status: Text
    var
        O365SalesDocument: Record "O365 Sales Document";
    begin
        O365SalesDocument.SetRange("No.", SalesInvoiceHeader."No.");
        O365SalesDocument.SetRange(Posted, true);
        if O365SalesDocument.OnFind('+') then
            Status := O365SalesDocument."Outstanding Status";
    end;

    local procedure GetTaxSummarizedLines(var TempSalesTaxAmountLine: Record "Sales Tax Amount Line" temporary)
    var
        TaxArea: Record "Tax Area";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin
        if not TaxArea.Get(SalesInvoiceHeader."Tax Area Code") then
            exit;
        SalesTaxCalculate.StartSalesTaxCalculation();
        if TaxArea."Use External Tax Engine" then
            SalesTaxCalculate.CallExternalTaxEngineForDoc(DATABASE::"Sales Invoice Header", 0, SalesInvoiceHeader."No.")
        else begin
            SalesTaxCalculate.AddSalesInvoiceLines(SalesInvoiceHeader."No.");
            SalesTaxCalculate.EndSalesTaxCalculation(SalesInvoiceHeader."Posting Date");
        end;
        TempSalesTaxAmountLine.DeleteAll();
        SalesTaxCalculate.GetSalesTaxAmountLineTable(TempSalesTaxAmountLine);
        SalesTaxCalculate.GetSummarizedSalesTaxTable(TempSalesTaxAmountLine);
    end;
}
#endif

