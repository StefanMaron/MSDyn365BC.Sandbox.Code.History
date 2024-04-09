codeunit 160800 "G/L Account conveted -Indent"
{

    trigger OnRun()
    begin
        /*IF NOT
           CONFIRM(
             Text000 +
             Text001 +
             Text002 +
             Text003,TRUE)
        THEN
          EXIT;
        */
        Indent;

    end;

    var
        Text000: Label 'This function updates the indentation of all the G/L accounts in the chart of accounts. ';
        Text001: Label 'All accounts between a Begin-Total and the matching End-Total are indented one level. ';
        Text002: Label 'The Totaling for each End-total is also updated.\\';
        Text003: Label 'Do you want to indent the chart of accounts?';
        Text004: Label 'Indenting the Chart of Accounts #1##########';
        Text005: Label 'End-Total %1 is missing a matching Begin-Total.';
        ArrayExceededErr: Label 'You can only indent %1 levels for accounts of the type Begin-Total.', Comment = '%1 = A number bigger than 1';
        GLAcc: Record "G/L Account";
        Window: Dialog;
        AccNo: array[10] of Code[20];
        i: Integer;
        icglacc: Record "IC G/L Account";

    procedure Indent()
    begin
        Window.Open(Text004);

        GLAcc.SetCurrentKey("No.");
        with GLAcc do
            if Find('-') then
                repeat
                    Window.Update(1, "No.");

                    if "Account Type" = "Account Type"::"End-Total" then begin
                        if i < 1 then
                            Error(
                              Text005,
                              "No.");
                        Totaling := AccNo[i] + '..' + "No.";
                        i := i - 1;
                    end;

                    Indentation := i;
                    Modify();

                    if "Account Type" = "Account Type"::"Begin-Total" then begin
                        i := i + 1;
                        if i > ArrayLen(AccNo) then
                            Error(ArrayExceededErr, ArrayLen(AccNo));
                        AccNo[i] := "No.";
                    end;
                    CalcFields("Balance at Date", "Net Change", "Budgeted Amount", Balance, "Budget at Date", "Debit Amount",
                               "Credit Amount", "Budgeted Debit Amount", "Budgeted Credit Amount",
                               "Additional-Currency Net Change");
                    GLAcc.Modify();
                until Next = 0;

        Window.Close();
    end;

    procedure IndentIC()
    begin
        Window.Open(Text004);
        with icglacc do
            if Find('-') then
                repeat
                    Window.Update(1, "No.");

                    if "Account Type" = "Account Type"::"End-Total" then begin
                        if i < 1 then
                            Error(
                              Text005,
                              "No.");
                        i := i - 1;
                    end;

                    Indentation := i;
                    Modify();

                    if "Account Type" = "Account Type"::"Begin-Total" then begin
                        i := i + 1;
                        if i > ArrayLen(AccNo) then
                            Error(ArrayExceededErr, ArrayLen(AccNo));
                        AccNo[i] := "No.";
                    end;
                until Next = 0;

        Window.Close();
    end;
}

