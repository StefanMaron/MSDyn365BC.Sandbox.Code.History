﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Consolidation;

using System.Reflection;

table 11608 "BAS XML Field ID Setup"
{
    Caption = 'BAS XML Field ID Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "XML Field ID"; Text[80])
        {
            Caption = 'XML Field ID';
            NotBlank = true;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
            TableRelation = Field."No." where(TableNo = filter(11601));

            trigger OnValidate()
            begin
                if "Field No." <> 0 then begin
                    BASXMLFieldID.SetRange("Field No.", "Field No.");
                    BASXMLFieldID.SetRange("Setup Name", "Setup Name");
                    if BASXMLFieldID.FindFirst() then
                        Error(Text11600, "Field No.", BASXMLFieldID."XML Field ID");
                end;

                CalcFields("Field Description", "Field Label No.");
            end;
        }
        field(4; "Field Label No."; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = filter(11601),
                                                        "No." = field("Field No.")));
            Caption = 'Field Label No.';
            Editable = true;
            FieldClass = FlowField;
        }
        field(5; "Field Description"; Text[80])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = filter(11601),
                                                              "No." = field("Field No.")));
            Caption = 'Field Description';
            Editable = true;
            FieldClass = FlowField;
        }
        field(6; "Setup Name"; Code[20])
        {
            Caption = 'Setup Name';
            TableRelation = "BAS XML Field Setup Name".Name;
        }
        field(7; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
        }
    }

    keys
    {
        key(Key1; "Setup Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "XML Field ID")
        {
        }
        key(Key3; "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        BASXMLFieldID: Record "BAS XML Field ID Setup";
        Text11600: Label 'Field No. %1 has already been entered for XML Field ID %2.';
}

