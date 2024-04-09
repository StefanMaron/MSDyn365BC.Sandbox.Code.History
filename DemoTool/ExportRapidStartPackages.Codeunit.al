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
        with ConfigPackage do begin
            if FindSet() then
                repeat
                    ConfigPackageTable.SetRange("Package Code", Code);
                    ConfigXMLExchange.SetCalledFromCode(true);
                    TempFileName := FileMgt.ServerTempFileName('');
                    ConfigXMLExchange.ExportPackageXML(ConfigPackageTable, TempFileName);

                    CompressedFileName :=
                      FileMgt.CombinePath(FileMgt.GetDirectoryName(TempFileName), StrSubstNo('%1.%2.rapidstart', "Product Version", Code));
                    if FileMgt.ServerFileExists(CompressedFileName) then
                        FileMgt.DeleteServerFile(CompressedFileName);
                    ConfigPckgCompressionMgt.ServersideCompress(TempFileName, CompressedFileName);
                until Next = 0;
        end;
    end;

    var
        ConfigPckgCompressionMgt: Codeunit "Config. Pckg. Compression Mgt.";
        FileMgt: Codeunit "File Management";
}

