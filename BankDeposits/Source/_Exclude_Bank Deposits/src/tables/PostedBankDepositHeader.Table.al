namespace Microsoft.Bank.Deposit;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using System.Globalization;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.GeneralLedger.Ledger;

table 1691 "Posted Bank Deposit Header"
{
    Caption = 'Posted Bank Deposit Header';
    DataCaptionFields = "No.";
    LookupPageID = "Posted Bank Deposit List";
    Permissions = tabledata "Bank Acc. Comment Line" = rd,
                  tabledata "Posted Bank Deposit Line" = r;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(4; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Total Deposit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Total Deposit Amount';
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(8; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(9; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(10; "Bank Acc. Posting Group"; Code[20])
        {
            Caption = 'Bank Acc. Posting Group';
            TableRelation = "Bank Account Posting Group";
        }
        field(11; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(12; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
        field(13; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(14; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(15; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(16; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
        }
        field(21; Comment; Boolean)
        {
            CalcFormula = exist("Bank Acc. Comment Line" where("Table Name" = const("Posted Bank Deposit Header"),
                                                           "Bank Account No." = field("Bank Account No."),
                                                           "No." = field("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning disable AA0232
        field(22; "Total Deposit Lines"; Decimal)
#pragma warning restore
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = sum("Posted Bank Deposit Line".Amount where("Bank Deposit No." = field("No.")));
            Caption = 'Total Deposit Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Format Region"; Text[80])
        {
            Caption = 'Format Region';
            TableRelation = "Language Selection"."Language Tag";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Bank Account No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        BankAccCommentLine: Record "Bank Acc. Comment Line";
    begin
        TestField("No. Printed");

        BankAccCommentLine.SetRange("Table Name", DATABASE::"Posted Bank Deposit Header");
        BankAccCommentLine.SetRange("Bank Account No.", "Bank Account No.");
        BankAccCommentLine.SetRange("No.", "No.");
        BankAccCommentLine.DeleteAll();

        PostedBankDepositDelete.Run(Rec);
        exit;
    end;

    var
        PostedBankDepositDelete: Codeunit "Posted Bank Deposit-Delete";
        DimensionManagement: Codeunit DimensionManagement;
        UnableToFindGLRegisterErr: Label 'Cannot find a G/L Register for the selected posted bank deposit.';
        UnableToFindGLRegisterTelemetryErr: Label 'Cannot find a G/L Register for the selected posted bank deposit %1.', Locked = true;

    // no commits during the method execution. if one line fails to reverse, reversal of lines before it must not be committed
    [CommitBehavior(CommitBehavior::Ignore)]
    internal procedure ReverseTransactions(): Boolean
    var
        ReversalEntry: Record "Reversal Entry";
        Attributes: Dictionary of [Text, Text];
        GLRegNo: Integer;
    begin
        OnBeforeUndoPostedBankDeposit(Rec);

        if not FindGLRegisterNo(GLRegNo) then begin
            Attributes.Add('Posted Bank Deposit No.', "No.");
            Session.LogMessage('0000GXF', UnableToFindGLRegisterTelemetryErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Attributes);
            Error(UnableToFindGLRegisterErr);
        end;

        ReversalEntry.ReverseRegister(GLRegNo);
        OnAfterUndoPostedBankDeposit(Rec);
        exit(true);
    end;

    internal procedure FindGLRegisterNo(var GLRegNo: Integer): Boolean
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GLRegister: Record "G/L Register";
    begin
        PostedBankDepositLine.SetRange("Bank Deposit No.", "No.");
        if not PostedBankDepositLine.FindFirst() then
            exit(false);

        GLRegister.SetFilter("From Entry No.", '<=' + Format(PostedBankDepositLine."Entry No."));
        GLRegister.SetFilter("To Entry No.", '>=' + Format(PostedBankDepositLine."Entry No."));

        if not GLRegister.FindFirst() then
            exit(false);

        GLRegNo := GLRegister."No.";
        exit(true);
    end;

    internal procedure ShowDocDim()
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", TableCaption() + ' ' + "No.");
    end;

    internal procedure IsReversed(): Boolean
    var
        GLRegister: Record "G/L Register";
        GLRegNo: Integer;
    begin
        if not Rec.FindGLRegisterNo(GLRegNo) then
            exit(false);

        GLRegister.Get(GLRegNo);
        exit(GLRegister.Reversed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUndoPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUndoPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    begin
    end;

}

