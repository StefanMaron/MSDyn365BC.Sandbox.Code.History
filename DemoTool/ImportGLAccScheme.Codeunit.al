codeunit 160805 "Import GLAcc. Scheme"
{

    trigger OnRun()
    begin
        //lang := GLOBALLANGUAGE();
        kontoskjema.DeleteAll();
        analyse.DeleteAll();
        dds.Get();

        lesfil2;
        lesfil3;
    end;

    var
        dds: Record "Demo Data Setup";
        byte: Text[1024];
        int: Integer;
        kontokonv: Record "GL Accounts Conversion";
        kontoskjema: Record "Acc. Schedules Conversion";
        analyse: Record "Analysis Conversion";
        lang: Integer;

    procedure lesfil2()
    var
        f: File;
        strin: InStream;
        txt: Text[1024];
    begin
        f.TextMode(true);
        f.WriteMode(false);
        f.Open('localfiles\accschedules.txt');

        f.CreateInStream(strin);
        //Starting a loop
        while not (strin.EOS()) do begin
            int := strin.ReadText(txt);
            convert2(txt);
        end;
        f.Close();
    end;

    procedure lesfil3()
    var
        f: File;
        strin: InStream;
        txt: Text[1024];
    begin
        f.TextMode(true);
        f.WriteMode(false);
        f.Open('localfiles\analysis.txt');

        f.CreateInStream(strin);
        //Starting a loop
        while not (strin.EOS()) do begin
            int := strin.ReadText(txt);
            convert3(txt);
        end;
        f.Close();
    end;

    procedure convert2(txt: Text[1024])
    begin
        with kontoskjema do begin
            Reset();
            Init();
            "Schedule Name" := CopyStr(txt, 1, 10);
            Evaluate("Line No.", CopyStr(txt, 12, 7));
            Evaluate("Totaling (New)", CopyStr(txt, 101, 80));
            Insert();
        end;
    end;

    procedure convert3(txt: Text[1024])
    begin
        with analyse do begin
            Reset();
            Init();
            "Analysis Code" := CopyStr(txt, 1, 10);
            Evaluate("GL Acc Filter (New)", CopyStr(txt, 20, 250));
            Insert();
        end;
    end;
}

