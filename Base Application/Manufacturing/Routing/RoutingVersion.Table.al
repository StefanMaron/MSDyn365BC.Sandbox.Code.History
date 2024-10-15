// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Routing;

using Microsoft.Foundation.NoSeries;

table 99000786 "Routing Version"
{
    Caption = 'Routing Version';
    DrillDownPageID = "Routing Version List";
    LookupPageID = "Routing Version List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            NotBlank = true;
            TableRelation = "Routing Header";
        }
        field(2; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(20; Status; Enum "Routing Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            var
                RoutingHeader: Record "Routing Header";
                SkipCommit: Boolean;
            begin
                if (Status <> xRec.Status) and (Status = Status::Certified) then begin
                    RoutingHeader.Get("Routing No.");
                    CheckRouting.Calculate(RoutingHeader, "Version Code");
                end;
                Modify(true);

                SkipCommit := false;
                OnValidateStatusBeforeCommit(Rec, SkipCommit);
                if not SkipCommit then
                    Commit();
            end;
        }
        field(21; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Serial,Parallel';
            OptionMembers = Serial,Parallel;

            trigger OnValidate()
            begin
                if Status = Status::Certified then
                    FieldError(Status);
            end;
        }
        field(22; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(50; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Routing No.", "Version Code")
        {
            Clustered = true;
        }
        key(Key2; "Routing No.", "Starting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RtngLine: Record "Routing Line";
    begin
        RtngLine.LockTable();
        RtngLine.SetRange("Routing No.", "Routing No.");
        RtngLine.SetRange("Version Code", "Version Code");
        RtngLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
#endif
    begin
        if "Version Code" = '' then begin
            RoutingHeader.Get("Routing No.");
            RoutingHeader.TestField("Version Nos.");
#if not CLEAN24
            NoSeriesMgt.RaiseObsoleteOnBeforeInitSeries(RoutingHeader."Version Nos.", xRec."No. Series", 0D, VersionCode, "No. Series", IsHandled);
            if not IsHandled then begin
#endif
                "No. Series" := RoutingHeader."Version Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                VersionCode := NoSeries.GetNextNo("No. Series");
#if not CLEAN24
                NoSeriesMgt.RaiseObsoleteOnAfterInitSeries("No. Series", RoutingHeader."Version Nos.", 0D, VersionCode);
            end;
#endif
            if StrLen(VersionCode) > MaxStrLen("Version Code") then
                Error(Text000,
                  FieldCaption("Version Code"),
                  NoSeriesLine.FieldCaption("Starting No."),
                  RoutingHeader."Version Nos.",
                  NoSeriesRec.TableCaption(),
                  MaxStrLen("Version Code"));

            "Version Code" := VersionCode;
        end;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin
        if Status = Status::Certified then
            Error(Text001, TableCaption(), FieldCaption(Status), Format(Status));
    end;

    var
        NoSeriesRec: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        RoutingHeader: Record "Routing Header";
        RtngVersion: Record "Routing Version";
        CheckRouting: Codeunit "Check Routing Lines";
#pragma warning disable AA0074
#pragma warning disable AA0470
        Text000: Label 'The new %1 cannot be generated by default\because the %2 for %3 %4 contains more than %5 characters.';
#pragma warning restore AA0470
#pragma warning restore AA0074
        VersionCode: Code[20];
#pragma warning disable AA0074
#pragma warning disable AA0470
        Text001: Label 'You cannot rename the %1 when %2 is %3.';
#pragma warning restore AA0470
#pragma warning restore AA0074

    procedure AssistEdit(OldRoutVersion: Record "Routing Version"): Boolean
    var
        NoSeries: Codeunit "No. Series";
    begin
        RtngVersion := Rec;
        RoutingHeader.Get(RtngVersion."Routing No.");
        RoutingHeader.TestField("Version Nos.");
        if NoSeries.LookupRelatedNoSeries(RoutingHeader."Version Nos.", OldRoutVersion."No. Series", RtngVersion."No. Series") then begin
            VersionCode := NoSeries.GetNextNo(RtngVersion."No. Series");
            if StrLen(VersionCode) > MaxStrLen(RtngVersion."Version Code") then
                Error(Text000,
                  RtngVersion.FieldCaption(RtngVersion."Version Code"),
                  NoSeriesLine.FieldCaption("Starting No."),
                  RoutingHeader."Version Nos.",
                  NoSeriesRec.TableCaption(),
                  MaxStrLen(RtngVersion."Version Code"));

            RtngVersion."Version Code" := VersionCode;
            Rec := RtngVersion;
            exit(true);
        end;
    end;

    procedure Caption(): Text
    var
        RtngHeader: Record "Routing Header";
    begin
        if GetFilters = '' then
            exit('');

        if "Routing No." = '' then
            exit('');

        RtngHeader.Get("Routing No.");
        exit(
          StrSubstNo(
            '%1 %2 %3', RtngHeader."No.", RtngHeader.Description, "Version Code"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStatusBeforeCommit(var RoutingVersion: Record "Routing Version"; var SkipCommit: Boolean)
    begin
    end;
}

