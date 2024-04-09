codeunit 101039 "Create Purchase Line"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        InsertData(1, '106001', 2, '1964-S', XGREEN, 14, 0, 0, '', '', '', '', '');
        InsertData(1, '106002', 2, '1964-W', XGREEN, 15, 0, 0, '', '', '', '', '');
        InsertData(1, '106002', 2, '1964-W', XBLUE, 25, 0, 0, '', '', '', '', '');
        InsertData(1, '106003', 2, '70060', XRED, 250, 0, 0, '', '', '', '', '');
        InsertData(1, '106003', 2, '70060', XBLUE, 500, 0, 0, '', '', '', '', '');
        InsertData(1, '106003', 2, '70011', XBLUE, 52, 0, 0, '', '', '', '', '');
        InsertData(1, '106004', 2, '70104', XBLUE, 800, 0, 0, '', '', '', '', '');
        InsertData(1, '106005', 2, '1900-S', XYELLOW, 160, 0, 0, '', '', '', '', '');
        InsertData(1, '106006', 2, '1924-W', XGREEN, 5, 0, 0, '', '', '', '', '');
        InsertData(1, '106006', 2, '1924-W', XYELLOW, 15, 0, 0, '', '', '', '', '');
        InsertData(1, '106006', 2, '1928-W', XGREEN, 20, 0, 0, '', '', '', '', '');
        InsertData(1, '106006', 2, '1928-W', XYELLOW, 41, 0, 0, '', '', '', '', '');
        InsertData(1, '106007', 2, '1952-W', XBLUE, 7, 0, 0, '', '', '', '', '');
        InsertData(1, '106007', 2, '1952-W', XRED, 6, 0, 0, '', '', '', '', '');
        InsertData(1, '106008', 2, '1964-W', XYELLOW, 8, 0, 0, '', '', '', '', '');
        InsertData(1, '106008', 2, '1964-W', XGREEN, 9, 0, 0, '', '', '', '', '');
        InsertData(1, '106009', 2, '1976-W', XBLUE, 2, 0, 0, '', '', '', '', '');
        InsertData(1, '106009', 2, '1976-W', XRED, 4, 0, 0, '', '', '', '', '');
        InsertData(1, '106010', 2, '1952-W', '', 88, 0, 0, '', '', '', '', '');
        InsertData(1, '106011', 2, '1980-S', '', 100, 0, 0, '', '', '', '', '');
        InsertData(1, '106012', 2, '70000', '', 2000, 0, 0, '', '', '', '', '');
        InsertData(1, '106012', 2, '70001', '', 2000, 0, 0, '', '', '', '', '');
        InsertData(1, '106012', 2, '70003', '', 500, 0, 0, '', '', '', '', '');
        InsertData(1, '106013', 2, '70010', '', 25, 0, 0, '', '', '', '', '');
        InsertData(1, '106014', 2, '70060', '', 1000, 0, 0, '', '', '', '', '');
        InsertData(1, '106015', 4, XFA000010, '', 1, 1, 30000, XINS000010, '', '', '', '');
        InsertData(1, '106016', 4, XFA000020, '', 1, 1, 42000, XINS000020, '', '', '', '');
        InsertData(1, '106017', 4, XFA000030, '', 1, 1, 15000, XINS000030, '', '', '', '');
        InsertData(1, '106018', 4, XFA000050, '', 1, 1, 6600, XINS000040, '', '', '', '');
        InsertData(1, '106019', 4, XFA000060, '', 1, 1, 4512, XINS000040, '', '', '', '');
        InsertData(1, '106020', 4, XFA000070, '', 1, 1, 3024, XINS000040, '', '', '', '');
        InsertData(1, '106021', 4, XFA000080, '', 1, 1, 3840, XINS000040, '', '', '', '');
        InsertData(1, '106022', 4, XFA000090, '', 1, 1, 7140, XINS000040, '', '', '', '');
        InsertData(1, '106023', 2, '80100', XGREEN, 6, 0, 0, '', '', '', '', '');
        InsertDataAndUpdateUnitOfMeasure(1, '106024', 2, '1896-S', XGREEN, 2, CreateUnitOfMeasure.GetBoxUnitOfMeasureCode());
        CreateINPurchOrderLines();

        // Add new orders here
        InsertData(2, '108001', 4, XFA000050, '', 1, 2, 20000, '', XSERVICE, '', '', '');
        InsertData(2, '108002', 4, XFA000060, '', 1, 2, 600, '', XSERVICE, '', '', '');
        InsertData(2, '108003', 4, XFA000070, '', 1, 2, 400, '', XSERVICE, '', '', '');
        InsertData(2, '108004', 4, XFA000080, '', 1, 2, 1200, '', XSERVICE, '', '', '');
        InsertData(2, '108005', 4, XFA000090, '', 1, 2, 2000, '', XSERVICE, '', '', '');
        InsertData(2, '108006', 4, XFA000010, '', 1, 2, 20000, '', XSERVICE, '', '', '');
        InsertData(2, '108007', 4, XFA000020, '', 1, 2, 600, '', XSERVICE, '', '', '');
        InsertData(2, '108008', 4, XFA000030, '', 1, 2, 400, '', XSERVICE, '', '', '');
        InsertDataAndUpdateUnitCost(2, '108009', 2, '70000', '', 10, 1879.83 / 10);
        InsertDataAndUpdateUnitCost(2, '108010', 2, '70000', '', 3, 563.95 / 3);
        InsertDataAndUpdateUnitCost(2, '108011', 2, '70000', '', 2, 375.96 / 2);
        InsertDataAndUpdateUnitCost(2, '108012', 2, '70000', '', 6, 1127.89 / 6);
        InsertDataAndUpdateUnitCost(2, '108013', 2, '70000', '', 5, 939.91 / 5);
        InsertDataAndUpdateUnitCost(2, '108014', 2, '70000', '', 12, 2255.78 / 12);
        InsertDataAndUpdateUnitCost(2, '108015', 2, '70000', '', 30, 5639.46 / 30);
        InsertDataAndUpdateUnitCost(2, '108016', 2, '70000', '', 25, 4699.55 / 25);

        CreateINPurchInvoiceLines();
        // Add new invoices here

        InsertData(3, '109001', 2, '1968-W', '', 40, 0, 0, '', '', '', '', '');
        InsertData(3, '109002', 2, '70003', '', 200, 0, 0, '', '', '', '', '');

        CreateINPurchCrMemoLines();
        // Add new credit memos here
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CreateUnitOfMeasure: Codeunit "Create Unit of Measure";
        "Line No.": Integer;
        "Previous Document No.": Code[20];
        XGREEN: Label 'GREEN';
        XBLUE: Label 'BLUE';
        XRED: Label 'RED';
        XYELLOW: Label 'YELLOW';
        XFA000010: Label 'FA000010';
        XFA000020: Label 'FA000020';
        XFA000030: Label 'FA000030';
        XFA000050: Label 'FA000050';
        XFA000060: Label 'FA000060';
        XFA000070: Label 'FA000070';
        XFA000080: Label 'FA000080';
        XINS000010: Label 'INS000010';
        XINS000020: Label 'INS000020';
        XFA000090: Label 'FA000090';
        XINS000030: Label 'INS000030';
        XINS000040: Label 'INS000040';
        XSERVICE: Label 'SERVICE';
        GSTCredit: Enum "GST Credit";

    procedure InsertData("Document Type": Integer; "Document No.": Code[20]; Type: Integer; "No.": Code[20]; "Location Code": Code[10]; Quantity: Decimal; "FA Posting Type": Integer; "Direct Unit Cost": Decimal; "Insurance No.": Code[20];
     "Maintenance Code": Code[10]; SectionCode: Code[20]; NOR: Code[20]; Act: Code[20])
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", "Document Type");
        PurchaseLine.Validate("Document No.", "Document No.");

        case "Previous Document No." of
            "Document No.":
                begin
                    "Line No." := "Line No." + 10000;
                    PurchaseLine.Validate("Line No.", "Line No.");
                end;
            else begin
                "Line No." := 10000;
                "Previous Document No." := "Document No.";
                PurchaseLine.Validate("Line No.", "Line No.");
            end;
        end;

        PurchaseLine.Validate(Type, Type);
        PurchaseLine.Validate("No.", "No.");
        PurchaseHeader.Get("Document Type", "Document No.");
        if PurchaseHeader."Location Code" <> '' then
            PurchaseLine.Validate("Location Code", PurchaseHeader."Location Code");
        PurchaseLine.Validate(Quantity, Quantity);

        if "FA Posting Type" > 0 then begin
            PurchaseLine.Validate("FA Posting Type", "FA Posting Type");
            PurchaseLine.Validate("Direct Unit Cost", "Direct Unit Cost");
            PurchaseLine.Validate("Insurance No.", "Insurance No.");
            PurchaseLine.Validate("Maintenance Code", "Maintenance Code");
        end;
        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            PurchaseLine.Validate("Direct Unit Cost", "Direct Unit Cost");
        PurchaseLine."TDS Section Code" := SectionCode;
        PurchaseLine."Nature of Remittance" := NOR;
        PurchaseLine."Act Applicable" := Act;
        PurchaseLine.Insert();

        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PO-1001' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PO-1002' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PO-1003' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PO-1004' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PO-1005' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PI-1001' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PI-1002' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PI-1003' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PI-1004' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        if GetVendorInvoiceOrCrMemoNo(PurchaseLine."Document Type", PurchaseLine."Document No.") = 'PI-1005' then
            UpdateGSTValue(PurchaseLine, GSTCredit::Availment, '', '');
        CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
    end;

    local procedure InsertDataAndUpdateUnitCost(DocumentType: Integer; DocumentNo: Code[20]; Type: Integer; No: Code[20]; LocationCode: Code[10]; Quantity: Decimal; DirectUnitCost: Decimal)
    begin
        InsertData(DocumentType, DocumentNo, Type, No, LocationCode, Quantity, 0, 0, '', '', '', '', '');
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);
    end;

    local procedure InsertDataAndUpdateUnitOfMeasure(DocumentType: Integer; DocumentNo: Code[20]; Type: Integer; No: Code[20]; LocationCode: Code[10]; Quantity: Decimal; UnitOfMeasureCode: Code[10])
    begin
        InsertData(DocumentType, DocumentNo, Type, No, LocationCode, Quantity, 0, 0, '', '', '', '', '');
        PurchaseLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
        PurchaseLine.Modify(true);
    end;

    procedure InsertTDSData("Document Type": Integer; "Document No.": Code[20]; Type: Integer; "No.": Code[20]; DirectUnitCost: Decimal; Quantity: Decimal; SectionCode: Code[20]; NOR: Code[20]; Act: Code[20])
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", "Document Type");
        PurchaseLine.Validate("Document No.", "Document No.");

        case "Previous Document No." of
            "Document No.":
                begin
                    "Line No." := "Line No." + 10000;
                    PurchaseLine.Validate("Line No.", "Line No.");
                end;
            else begin
                "Line No." := 10000;
                "Previous Document No." := "Document No.";
                PurchaseLine.Validate("Line No.", "Line No.");
            end;
        end;

        PurchaseLine.Validate(Type, Type);
        PurchaseLine.Validate("No.", "No.");
        PurchaseLine.Validate(Quantity, Quantity);
        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine."TDS Section Code" := SectionCode;
        PurchaseLine."Nature of Remittance" := NOR;
        PurchaseLine.Insert();
        CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
    end;

    procedure GetDocumentNo(PurchDocType: Enum "Purchase Document Type"; InvoiceNo: Code[20]): Code[20]
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetRange("Document Type", PurchDocType);
        if PurchDocType in [PurchDocType::Order, PurchDocType::Invoice] then
            PurchHeader.SetRange("Vendor Invoice No.", InvoiceNo)
        else
            PurchHeader.SetRange("Vendor Cr. Memo No.", InvoiceNo);
        PurchHeader.FindFirst();
        exit(PurchHeader."No.");
    end;

    procedure GetVendorInvoiceOrCrMemoNo(PurchDocType: Enum "Purchase Document Type"; DocumentNo: Code[20]): Code[20]
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.Get(PurchDocType, DocumentNo);
        if PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice] then
            exit(PurchHeader."Vendor Invoice No.")
        else
            exit(PurchHeader."Vendor Cr. Memo No.");
    end;

    procedure UpdateGSTValue(var PurchLine: Record "Purchase Line"; GSTCredit: Enum "GST Credit"; HSNSAC: Code[20]; GSTGrp: Code[20])
    begin
        PurchLine."GST Credit" := GSTCredit;
        if HSNSAC <> '' then
            PurchLine."HSN/SAC Code" := HSNSAC;
        if GSTGrp <> '' then
            PurchLine."GST Group Code" := GSTGrp;
        PurchLine.Modify();
    end;

    local procedure InsertRefInvNo(DocType: Integer; DocNo: Code[20]; SourceNo: Code[20])
    var
        RefInvNo: Record "Reference Invoice No.";
    begin
        RefInvNo.Init();
        if DocType = 3 then
            RefInvNo."Document Type" := RefInvNo."Document Type"::"Credit Memo";
        if DocType = 5 then
            RefInvNo."Document Type" := RefInvNo."Document Type"::"Return Order";
        RefInvNo."Document No." := DocNo;
        RefInvNo."Source Type" := RefInvNo."Source Type"::Vendor;
        RefInvNo."Source No." := SourceNo;
        RefInvNo."Reference Invoice Nos." := 'DUMMY-' + DocNo;
        RefInvNo.Verified := true;
        RefInvNo.Insert();
    end;

    procedure CreateINPurchOrderLines()
    begin
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1001'), 2, '1936-S', 'BLUE', 10, 0, 100, '', '', '', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1001'), 2, '1968-S', 'BLUE', 20, 0, 100, '', '', '', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1002'), 2, '1936-S', 'BLUE', 10, 0, 100, '', '', '', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1002'), 2, '1968-S', 'BLUE', 20, 0, 100, '', '', '', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1003'), 1, '8240', 'BLUE', 1, 0, 10000, '', '', 'S', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1004'), 1, '8240', 'BLUE', 1, 0, 10000, '', '', 'S', '', '');
        InsertData(1, GetDocumentNo("Purchase Document Type"::Order, 'PO-1004'), 1, '8430', 'BLUE', 1, 0, 6000, '', '', '194J-PF', '', '');
    end;

    procedure CreateINPurchInvoiceLines()
    begin
        InsertData(2, GetDocumentNo("Purchase Document Type"::Invoice, 'PI-1001'), 1, '8112', 'BLUE', 1, 0, 1000, '', '', '', '', '');
        InsertData(2, GetDocumentNo("Purchase Document Type"::Invoice, 'PI-1002'), 1, '8430', 'BLUE', 1, 0, 8000, '', '', '195', '16', 'A');
    end;

    procedure CreateINPurchCrMemoLines()
    begin
        InsertData(3, GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), 2, '1936-S', 'BLUE', 5, 0, 100, '', '', '', '', '');
        InsertData(3, GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), 2, '1968-S', 'BLUE', 2, 0, 100, '', '', '', '', '');
        InsertData(3, GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1002'), 1, '8112', 'BLUE', 1, 0, 100, '', '', '', '', '');

        InsertRefInvNo(3, GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), '10000');
        InsertRefInvNo(3, GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1002'), '10000');
    end;
}

