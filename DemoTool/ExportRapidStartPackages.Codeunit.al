codeunit 101930 "Export RapidStart Packages"
{

    trigger OnRun()
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        CompressedFileName: Text;
        TempFileName: Text;
    begin
        if ConfigPackage.FindSet() then
            repeat
                ConfigPackageTable.SetRange("Package Code", ConfigPackage.Code);
                ConfigXMLExchange.SetCalledFromCode(true);
                TempFileName := FileMgt.ServerTempFileName('');
                ConfigXMLExchange.ExportPackageXML(ConfigPackageTable, TempFileName);

                CompressedFileName :=
                  FileMgt.CombinePath(FileMgt.GetDirectoryName(TempFileName), StrSubstNo('%1.%2.rapidstart', ConfigPackage."Product Version", ConfigPackage.Code));
                if FileMgt.ServerFileExists(CompressedFileName) then
                    FileMgt.DeleteServerFile(CompressedFileName);
                ConfigPckgCompressionMgt.ServersideCompress(TempFileName, CompressedFileName);
            until ConfigPackage.Next() = 0;
    end;

    var
        ConfigPckgCompressionMgt: Codeunit "Config. Pckg. Compression Mgt.";
        FileMgt: Codeunit "File Management";
}

