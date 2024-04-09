#if not CLEAN22
xmlport 101907 "Intrastat - Transaction Types"
{
    Caption = 'Intrastat - Transaction Types';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    schema
    {
        textelement(Root)
        {
            tableelement("Transaction Type"; "Transaction Type")
            {
                XmlName = 'TransactionType';
                fieldelement(code; "Transaction Type".Code)
                {
                }
                textelement(descr)
                {
                    MinOccurs = Zero;
                }

                trigger OnBeforeInsertRecord()
                begin
                    "Transaction Type".Description := CopyStr(descr, 1, MaxStrLen("Transaction Type".Description));
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        if not "Transaction Type".IsEmpty() then
            "Transaction Type".DeleteAll();
    end;
}
#endif