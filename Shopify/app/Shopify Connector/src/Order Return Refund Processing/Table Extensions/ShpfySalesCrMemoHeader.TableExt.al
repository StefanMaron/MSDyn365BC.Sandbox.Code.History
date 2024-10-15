namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

tableextension 30108 "Shpfy Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(30103; "Shpfy Refund Id"; BigInteger)
        {
            Caption = 'Shopify Refund Id';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Shpfy Refund Header"."Refund Id";
        }
    }
}