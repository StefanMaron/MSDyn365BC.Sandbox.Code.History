tableextension 13685 "Sales Header Archive DK" extends "Sales Header Archive"
{
    fields
    {
        field(13600; "EAN No."; Code[13])
        {
            Caption = 'EAN No.';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(13602; "Account Code"; Text[30])
        {
            Caption = 'Account Code';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(13605; "Sell-to Contact Phone No."; Text[30])
        {
            Caption = 'Sell-to Contact Phone No.';
            DataClassification = SystemMetadata;
            ExtendedDatatype = PhoneNo;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(13606; "Sell-to Contact Fax No."; Text[30])
        {
            Caption = 'Sell-to Contact Fax No.';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(13607; "Sell-to Contact E-Mail"; Text[80])
        {
            Caption = 'Sell-to Contact E-Mail';
            DataClassification = SystemMetadata;
            ExtendedDatatype = EMail;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            ObsoleteTag = '15.0';
        }
        field(13608; "Sell-to Contact Role"; Option)
        {
            Caption = 'Sell-to Contact Role';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Moved to OIOUBL extension, the same table, same field name prefixed with OIOUBL-.';
            ObsoleteState = Removed;
            OptionCaption = ' ,,,Purchase Responsible,,,Accountant,,,Budget Responsible,,,Requisitioner';
            OptionMembers = " ",,,"Purchase Responsible",,,Accountant,,,"Budget Responsible",,,Requisitioner;
            ObsoleteTag = '15.0';
        }
        field(13620; "Payment Channel"; Option)
        {
            Caption = 'Payment Channel';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Deprecated.';
            ObsoleteState = Removed;
            OptionCaption = ' ,Payment Slip,Account Transfer,National Clearing,Direct Debit';
            OptionMembers = " ","Payment Slip","Account Transfer","National Clearing","Direct Debit";
            ObsoleteTag = '15.0';
        }
    }
}