﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 744 "VAT Report Line Relation"
{
    Caption = 'VAT Report Line Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Report No."; Code[20])
        {
            Caption = 'VAT Report No.';
            TableRelation = "VAT Report Header"."No.";
        }
        field(2; "VAT Report Line No."; Integer)
        {
            Caption = 'VAT Report Line No.';
            TableRelation = "VAT Report Line"."Line No.";
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(11; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1; "VAT Report No.", "VAT Report Line No.", "Table No.", "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        VATReportLineRelation: Record "VAT Report Line Relation";
    begin
        // One VAT Report line can have relations only to one table
        VATReportLineRelation.SetRange("VAT Report No.", "VAT Report No.");
        VATReportLineRelation.SetRange("VAT Report Line No.", "VAT Report Line No.");
        if VATReportLineRelation.FindFirst() then
            TestField("Table No.", VATReportLineRelation."Table No.");
    end;
}

