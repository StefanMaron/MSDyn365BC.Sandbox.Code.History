codeunit 119089 "Create Cost Acct. Jnl Template"
{

    trigger OnRun()
    var
        CostJournalTemplate: Record "Cost Journal Template";
    begin
        with CostJournalTemplate do begin
            Name := XCOSTACCT;
            Description := XStandardJournal;
            "Posting Report ID" := REPORT::"Cost Register";
            if not Insert then
                Modify();
        end;
    end;

    var
        XCOSTACCT: Label 'COSTACCT', Comment = 'COSTACCT stands for Cost Accounting.';
        XStandardJournal: Label 'Standard Journal';
}

