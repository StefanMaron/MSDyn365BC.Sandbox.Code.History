#if not CLEAN22
xmlport 101906 "Intrastat - Tariff Nos."
{
    Caption = 'Intrastat - Tariff Nos.';
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
            tableelement("Tariff Number"; "Tariff Number")
            {
                XmlName = 'TariffNos';
                fieldelement(no; "Tariff Number"."No.")
                {
                }
                textelement(description)
                {

                    trigger OnAfterAssignVariable()
                    begin
                        "Tariff Number".Description := CopyStr(description, 1, MaxStrLen("Tariff Number".Description));
                    end;
                }

                trigger OnBeforeInsertRecord()
                var
                    SpaceRemovedFromNo: Text;
                begin
                    SpaceRemovedFromNo := DelChr("Tariff Number"."No.", '=');
                    if StrLen(SpaceRemovedFromNo) <> 8 then
                        currXMLport.Skip();
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
        if not "Tariff Number".IsEmpty() then
            "Tariff Number".DeleteAll();
    end;
}
#endif