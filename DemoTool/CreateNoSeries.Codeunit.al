codeunit 101308 "Create No. Series"
{

    trigger OnRun()
    begin
        exit;
    end;

    var
        NoSeriesRelationship: Record "No. Series Relationship";
        NoSeries: Record "No. Series";

    procedure AddPrefix(SeriesCode: Code[20]; Prefix: Code[10])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", SeriesCode);
        NoSeriesLine.FindSet();
        repeat
            NoSeriesLine.Validate("Starting No.", Prefix + NoSeriesLine."Starting No.");
            NoSeriesLine.Modify();
        until NoSeriesLine.Next() = 0;
    end;

    procedure InitFinalSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; No: Integer)
    var
        StartingNo: Code[20];
        EndingNo: Code[20];
    begin
        StartingNo := '10' + Format(No);
        EndingNo := '10' + Format(No + 1);
        InsertSeries(
          SeriesCode, Code, Description,
          StartingNo + '001',
          EndingNo + '999',
          '',
          EndingNo + '995',
          1,
          false);
    end;

    procedure InitTempSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100])
    begin
        InitTempSeries(SeriesCode, Code, Description, 1);
    end;

    procedure InitTempSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; No: Integer)
    var
        StartingNo: Code[20];
        EndingNo: Code[20];
    begin
        StartingNo := Format(No);
        EndingNo := Format(No + 1);
        InsertSeries(
          SeriesCode, Code, Description,
          StartingNo + '001',
          EndingNo + '999',
          '',
          EndingNo + '995',
          1,
          false,
          false);
    end;

    procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning at No.": Code[20]; "Increment-by No.": Integer)
    begin
        InitBaseSeries(SeriesCode, "Code", Description, "Starting No.", "Ending No.", "Last Number Used", "Warning at No.", "Increment-by No.", false);
    end;

    internal procedure InitBaseSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning at No.": Code[20]; "Increment-by No.": Integer; "Allow Gaps": Boolean)
    begin
        InsertSeries(
          SeriesCode, Code, Description,
          "Starting No.", "Ending No.", "Last Number Used", "Warning at No.", "Increment-by No.", true, "Allow Gaps");
    end;

    procedure InsertSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning No.": Code[20]; "Increment-by No.": Integer; "Manual Nos.": Boolean)
    begin
        InsertSeries(SeriesCode, "Code", Description, "Starting No.", "Ending No.", "Last Number Used", "Warning No.", "Increment-by No.", "Manual Nos.", false);
    end;

    internal procedure InsertSeries(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning No.": Code[20]; "Increment-by No.": Integer; "Manual Nos.": Boolean; "Allow Gaps": Boolean)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := "Manual Nos.";
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine.Validate("Starting No.", "Starting No.");
        NoSeriesLine.Validate("Ending No.", "Ending No.");
        NoSeriesLine.Validate("Last No. Used", "Last Number Used");
        if "Warning No." <> '' then
            NoSeriesLine.Validate("Warning No.", "Warning No.");
        NoSeriesLine.Validate("Increment-by No.", "Increment-by No.");
        NoSeriesLine.Validate("Allow Gaps in Nos.", "Allow Gaps");
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);

        SeriesCode := Code;
    end;

    procedure InsertRelation("Code": Code[20]; "Series Code": Code[20])
    begin
        NoSeriesRelationship.Init();
        NoSeriesRelationship.Code := Code;
        NoSeriesRelationship."Series Code" := "Series Code";
        NoSeriesRelationship.Insert();

        NoSeries.Get("Series Code");
        NoSeries."Default Nos." := false;
        NoSeries.Modify();
    end;

    procedure InitBaseSeries2(var SeriesCode: Code[20]; "Code": Code[20]; Description: Text[100]; "Starting No.": Code[20]; "Ending No.": Code[20]; "Last Number Used": Code[20]; "Warning at No.": Code[20]; "Increment-by No.": Integer)
    begin
        // NAVCZ
        InsertSeries(
          SeriesCode, Code, Description,
          "Starting No.", "Ending No.", "Last Number Used", "Warning at No.", "Increment-by No.", false);
    end;
}

