table 31063 "Specific Movement"
{
    Caption = 'Specific Movement';
    ObsoleteState = Removed;
    ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
    ObsoleteTag = '21.0';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}