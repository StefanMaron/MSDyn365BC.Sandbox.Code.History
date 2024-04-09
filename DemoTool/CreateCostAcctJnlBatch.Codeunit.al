codeunit 119090 "Create Cost Acct. Jnl Batch"
{

    trigger OnRun()
    begin
        InsertData(XCOSTACCT, XDEFAULT, XStandardJournal);
        InsertData(XCOSTACCT, XINTINVC, XInternalInvoicing);
        InsertData(XCOSTACCT, XDEPRECIAT, XQuarterlyDepreciations);
    end;

    var
        XCOSTACCT: Label 'COSTACCT', Comment = 'COSTACCT stands for Cost Accounting.';
        XDEFAULT: Label 'DEFAULT', Comment = 'Default is a name of Batch.';
        XStandardJournal: Label 'Standard Journal';
        XINTINVC: Label 'INTINVC', Comment = 'INTINVC stands for Internal Invoicing.';
        XInternalInvoicing: Label 'Internal Invoicing';
        XDEPRECIAT: Label 'DEPRECIAT', Comment = 'DEPRECIAT stands for Depreciation.';
        XQuarterlyDepreciations: Label 'Quarterly Depreciations';

    procedure InsertData(TemplateName: Code[10]; BatchName: Code[10]; BatchDescription: Text[50])
    var
        CostJournalBatch: Record "Cost Journal Batch";
    begin
        with CostJournalBatch do begin
            Init();
            "Journal Template Name" := TemplateName;
            Name := BatchName;
            Description := BatchDescription;
            if not Insert then
                Modify();
        end;
    end;
}

