codeunit 117562 "Add Resource"
{

    trigger OnRun()
    begin
        DemoDataSetup.Get();
        InsertRec(XKatherine, XKatherineHulllc, XKATHERINEHULL, XHOUR, 49, 10.0, 53.9, 49.62617, 107,
          MakeAdjustments.AdjustDate(19020920D), XSERVICES, 'GB-N12 5XY', XHIGHVAT);
    end;

    var
        DemoDataSetup: Record "Demo Data Setup";
        CreatePostCode: Codeunit "Create Post Code";
        XKatherine: Label 'Katherine';
        XKatherineHulllc: Label 'Katherine Hull';
        xKATHERINEHULL: Label 'KATHERINE HULL';
        X14SidneyBoulevard: Label '14 Sidney Boulevard';
        XLondon: Label 'London';
        XServiceManager: Label 'Service Manager';
        XHOUR: Label 'HOUR';
        XSERVICES: Label 'SERVICES';
        XVAT10: Label 'VAT10';
        MakeAdjustments: Codeunit "Make Adjustments";
        XHIGHVAT: Label 'HIGH';

    procedure InsertRec(Fld1: Text[250]; Fld3: Text[250]; Fld4: Text[250]; Fld18: Text[250]; Fld19: Decimal; Fld20: Decimal; Fld21: Decimal; Fld22: Decimal; Fld24: Decimal; Fld26: Date; Fld51: Text[250]; Fld53: Text[250]; Fld58: Text[250])
    var
        NewRec: Record Resource;
        ResUnitOfMeasure: Record "Resource Unit of Measure";
        CreatePostCode: Codeunit "Create Post Code";
    begin
        NewRec.Init();
        Evaluate(NewRec."No.", Fld1);
        Evaluate(NewRec.Name, Fld3);
        Evaluate(NewRec."Search Name", Fld4);

        ResUnitOfMeasure.Init();
        Evaluate(ResUnitOfMeasure."Resource No.", Fld1);
        Evaluate(ResUnitOfMeasure.Code, Fld18);
        ResUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ResUnitOfMeasure."Related to Base Unit of Meas." := true;
        ResUnitOfMeasure.Insert();

        Evaluate(NewRec."Base Unit of Measure", Fld18);

        NewRec."Direct Unit Cost" := Fld19;
        NewRec.Validate(
          "Direct Unit Cost",
          Round(
            NewRec."Direct Unit Cost" * DemoDataSetup."Local Currency Factor",
            1 * DemoDataSetup."Local Precision Factor"));

        NewRec."Indirect Cost %" := Fld20;

        NewRec."Unit Cost" := Fld21;
        NewRec.Validate(
          "Unit Cost",
          Round(
            NewRec."Unit Cost" * DemoDataSetup."Local Currency Factor",
            1 * DemoDataSetup."Local Precision Factor"));

        NewRec."Profit %" := Fld22;

        NewRec."Unit Price" := Fld24;
        NewRec.Validate(
          "Unit Price",
          Round(
            NewRec."Unit Price" * DemoDataSetup."Local Currency Factor",
            1 * DemoDataSetup."Local Precision Factor"));

        NewRec."Last Date Modified" := Fld26;
        Evaluate(NewRec."Gen. Prod. Posting Group", Fld51);
        Evaluate(NewRec."Post Code", CreatePostCode.FindPostCode(Fld53));
        Evaluate(NewRec."VAT Prod. Posting Group", Fld58);
        NewRec.Insert();
    end;
}

