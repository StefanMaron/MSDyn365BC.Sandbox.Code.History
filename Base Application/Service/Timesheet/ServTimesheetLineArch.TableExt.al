namespace Microsoft.Projects.TimeSheet;

using Microsoft.Service.Document;

tableextension 6465 "Serv. Time Sheet Line Arch." extends "Time Sheet Line Archive"
{
    fields
    {
        field(13; "Service Order No."; Code[20])
        {
            Caption = 'Service Order No.';
            DataClassification = CustomerContent;
            TableRelation = if (Posted = const(false)) "Service Header"."No." where("Document Type" = const(Order));
        }
        field(14; "Service Order Line No."; Integer)
        {
            Caption = 'Service Order Line No.';
            DataClassification = CustomerContent;
        }
    }
}