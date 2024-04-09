#if not CLEAN21
codeunit 101855 "Create Payment Instructions"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
        InsertPaymentInstructions(XPmtInstrBankName, XPmtInstrBankText);

        InsertPaymentInstructions(XPmtInstrOnlineName, XPmtInstrOnlineText);

        InsertPaymentInstructions(XPmtInstrCheckName, XPmtInstrCheckText);

        SetDefaultPaymentInstructions(XPmtInstrCheckName);
    end;

    var
        XPmtInstrBankName: Label 'Bank payment';
        XPmtInstrBankText: Label 'Please pay by bank transfer to <your details here>.';
        XPmtInstrCheckName: Label 'Check payment';
        XPmtInstrCheckText: Label 'Please make checks payable to %1.', Comment = '%1 = Company name';
        XPmtInstrOnlineName: Label 'Online payment';
        XPmtInstrOnlineText: Label 'Please pay this invoice online.';

    local procedure InsertPaymentInstructions(Name: Text[20]; Instruction: Text): Integer
    var
        O365PaymentInstructions: Record "O365 Payment Instructions";
    begin
        O365PaymentInstructions.Init();
        O365PaymentInstructions.Name := Name;
        O365PaymentInstructions."Payment Instructions" :=
          CopyStr(Instruction, 1, MaxStrLen(O365PaymentInstructions."Payment Instructions"));
        O365PaymentInstructions.Insert(true);
        exit(O365PaymentInstructions.Id);
    end;

    local procedure SetDefaultPaymentInstructions(Name: Text[20])
    var
        O365PaymentInstructions: Record "O365 Payment Instructions";
    begin
        O365PaymentInstructions.SetRange(Name, Name);

        if O365PaymentInstructions.FindFirst() then begin
            O365PaymentInstructions.Validate(Default, true);
            O365PaymentInstructions.Modify(true);
        end;
    end;
}
#endif

