// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Contract;

table 932 "Contract Trend Buffer"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(5; "Period Type"; Option)
        {
            Caption = 'Period Type';
            OptionMembers = Day,Week,Month,Quarter,Year,Period;
            DataClassification = SystemMetadata;
        }
        field(6; "Period Name"; Text[50])
        {
            Caption = 'Period Name';
            DataClassification = SystemMetadata;
        }
        field(7; "Period Start"; Date)
        {
            Caption = 'Period Start';
            DataClassification = SystemMetadata;
        }
        field(8; "Period End"; Date)
        {
            Caption = 'Period End';
            DataClassification = SystemMetadata;
        }
        field(10; "Prepaid Income"; Decimal)
        {
            Caption = 'Prepaid Income';
            DataClassification = SystemMetadata;
        }
        field(11; "Posted Income"; Decimal)
        {
            Caption = 'Posted Income';
            DataClassification = SystemMetadata;
        }
        field(12; "Posted Cost"; Decimal)
        {
            Caption = 'Posted Cost';
            DataClassification = SystemMetadata;
        }
        field(13; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(15; Profit; Decimal)
        {
            Caption = 'Profit';
            DataClassification = SystemMetadata;
        }
        field(16; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Period Type", "Period Start")
        {
            Clustered = true;
        }
    }
}
