codeunit 161503 "Create CH VAT Posting Setup"
{

    trigger OnRun()
    begin
        with DemoDataSetup do begin
            Get();
            // Blanc
            InsertLine('', xCodeNormal, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine('', xCodeRed, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine('', xCodeBetrieb, 0.0, '2200', '1171', 'Z', 'E');
            InsertLine('', NoVATCode, 0.0, '2200', '1170', 'Z', 'E');

            // CH
            InsertLine(DomesticCode, xCodeNormal, 8.0, '2200', '1170', 'A', 'S');
            InsertLine(DomesticCode, xCodeRed, 2.4, '2200', '1170', 'B', 'S');
            InsertLine(DomesticCode, xCodeBetrieb, 8.0, '2200', '1171', 'A', 'S');
            InsertLine(DomesticCode, xCodeHalbNor, 3.66089, '2200', '1171', 'D', 'S');
            InsertLine(DomesticCode, NoVATCode, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine(DomesticCode, xCodeHotel, 3.6, '2200', '1170', 'C', 'S');
            InsertLine(DomesticCode, xCodeImport, 100, '', '1174', 'H', 'S');

            // Foreign
            InsertLine(ExportCode, xCodeNormal, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine(ExportCode, xCodeRed, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine(ExportCode, xCodeBetrieb, 0.0, '', '1171', 'Z', 'E');
            InsertLine(ExportCode, NoVATCode, 0.0, '2200', '1170', 'Z', 'E');

            // EU
            InsertLine(EUCode, xCodeNormal, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine(EUCode, xCodeRed, 0.0, '2200', '1170', 'Z', 'E');
            InsertLine(EUCode, xCodeBetrieb, 0.0, '', '1171', 'Z', 'E');
            InsertLine(EUCode, NoVATCode, 0.0, '2200', '1170', 'Z', 'E');
            // 5.00 NEW
            InsertLine(EUCode, xCodeHotel, 0.0, '2200', '1170', 'Z', 'E');
        end;
    end;

    var
        xCodeNormal: Label 'NORMAL';
        xCodeRed: Label 'RED';
        xCodeBetrieb: Label 'OPEXP';
        xCodeHalbNor: Label 'HALF NORM';
        xCodeHotel: Label 'HOTEL';
        xCodeImport: Label 'IMPORT';
        DemoDataSetup: Record "Demo Data Setup";
        VATPostingSetup: Record "VAT Posting Setup";

    procedure InsertLine(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; Percent: Decimal; SalesVATAccount: Code[20]; PurchaseVATAccount: Code[20]; VATID: Code[10]; TaxCategory: Code[10])
    begin
        with VATPostingSetup do begin
            Init();
            Validate("VAT Bus. Posting Group", VATBusPostingGroup);
            Validate("VAT Prod. Posting Group", VATProdPostingGroup);
            "VAT %" := Percent;
            "VAT Identifier" := VATID;
            "Adjust for Payment Discount" := true;
            Validate("Sales VAT Account", SalesVATAccount);
            Validate("Purchase VAT Account", PurchaseVATAccount);
            "Sales VAT Unreal. Account" := '';
            "Purch. VAT Unreal. Account" := '';
            "Tax Category" := TaxCategory;
            if Percent = 100 then
                "VAT Calculation Type" := "VAT Calculation Type"::"Full VAT"
            else
                "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
            "Unrealized VAT Type" := "Unrealized VAT Type"::" ";
            if not Insert then
                Modify();
        end;
    end;
}

