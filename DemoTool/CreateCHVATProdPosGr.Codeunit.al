codeunit 161502 "Create CH VAT Prod.Pos.Gr."
{

    trigger OnRun()
    var
        DemoDataSetup: Record "Demo Data Setup";
    begin
        InsertData(xCodeRed, xDescRed);
        InsertData(xCodeNormal, xDescNormal);
        InsertData(xCodeFrei, xDescFrei);

        InsertData(xCodeImport, xDescImport);
        InsertData(xCodeBetrieb, xDescBetrieb);
        InsertData(xCodeHotel, xDescHotel);
        InsertData(xCodeHalbNor, xDescHalbNor);

        DemoDataSetup.Get();
    end;

    var
        xCodeRed: Label 'RED';
        xCodeNormal: Label 'NORMAL';
        xCodeFrei: Label 'NO VAT';
        xCodeImport: Label 'IMPORT';
        xCodeBetrieb: Label 'OPEXP';
        xCodeHotel: Label 'HOTEL';
        xCodeHalbNor: Label 'HALF NORM';
        xDescRed: Label 'Reduced Rate, 2.4%';
        xDescNormal: Label 'Normal VAT Rate, 8.0%';
        xDescFrei: Label 'Tax Exempt';
        xDescImport: Label 'Import, Full Tax 100%';
        xDescBetrieb: Label 'Purch. VAT Operating Expenses 8.0%';
        xDescHotel: Label 'Hotels, 3.6%';
        xDescHalbNor: Label 'Half Standard Rate';
        "VAT Product Posting Group": Record "VAT Product Posting Group";
        XBASIC: Label 'BASIC', Comment = 'Basic is a name of Permission Set.';

    procedure InsertData(ActCode: Code[10]; ActDescription: Text[50])
    begin
        with "VAT Product Posting Group" do begin
            Init();
            Validate(Code, ActCode);
            Validate(Description, ActDescription);
            if not Insert then;
        end;
    end;
}

