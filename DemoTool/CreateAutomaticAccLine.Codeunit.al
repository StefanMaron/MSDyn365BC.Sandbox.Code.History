#if not CLEAN22
codeunit 160902 "Create Automatic Acc. Line"
{
    ObsoleteReason = 'Moved to Automatic Account Codes app.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun()
    begin
        InsertData('998110', -100, '', '');
        InsertData('998110', 30, '998110', XADM);
        InsertData('998110', 35, '998110', XPROD);
        InsertData('998110', 35, '998110', XSALES);
    end;

    var
        XADM: Label 'ADM';
        XPROD: Label 'PROD';
        XSALES: Label 'SALES';
        MakeAdjust: Codeunit "Make Adjustments";
        "Previous Document No.": Code[20];
        "Line No.": Integer;

    procedure InsertData("Automatic Acc. No.": Code[10]; "Allocation %": Decimal; "G/L Account No.": Code[20]; "Shortcut Dimension 1 Code": Code[20])
    var
        "Automatic Acc. Line": Record "Automatic Acc. Line";
    begin
        "Automatic Acc. Line".Init();
        "Automatic Acc. Line".Validate("Automatic Acc. No.", MakeAdjust.Convert("Automatic Acc. No."));
        "Automatic Acc. Line".Validate("Allocation %", "Allocation %");
        "Automatic Acc. Line".Validate("G/L Account No.", MakeAdjust.Convert("G/L Account No."));
        "Automatic Acc. Line".Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");

        case "Previous Document No." of
            "Automatic Acc. Line"."Automatic Acc. No.":
                begin
                    "Line No." := "Line No." + 10000;
                    "Automatic Acc. Line".Validate("Line No.", "Line No.");
                end;
            else begin
                "Line No." := 10000;
                "Previous Document No." := "Automatic Acc. Line"."Automatic Acc. No.";
                "Automatic Acc. Line".Validate("Line No.", "Line No.");
            end;
        end;

        "Automatic Acc. Line".Insert();
    end;
}
#endif
