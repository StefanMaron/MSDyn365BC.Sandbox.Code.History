#if not CLEAN21
codeunit 119205 "Create O365 Social Networks"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
        CreateSocialNetwork('FACEBOOK', FaceBookTxt);
        CreateSocialNetwork('TWITTER', TwitterTxt);
        CreateSocialNetwork('YOUTUBE', YoutubeTxt);
        CreateSocialNetwork('LINKEDIN', LinkedInTxt);
        CreateSocialNetwork('PINTEREST', PinterestTxt);
        CreateSocialNetwork('YELP', YelpTxt);
        CreateSocialNetwork('INSTAGRAM', InstagramTxt);
    end;

    var
        FaceBookTxt: Label 'Facebook';
        TwitterTxt: Label 'Twitter';
        YoutubeTxt: Label 'YouTube';
        LinkedInTxt: Label 'LinkedIn';
        PinterestTxt: Label 'Pinterest';
        YelpTxt: Label 'Yelp';
        InstagramTxt: Label 'Instagram';

    local procedure CreateSocialNetwork("Code": Code[10]; Name: Text)
    var
        O365SocialNetwork: Record "O365 Social Network";
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
        FilePath: Text;
        FileName: Text;
    begin
        FileName := StrSubstNo('Social - %1.png', Code);
        FilePath := ''; // server temp folder

        O365SocialNetwork.Init();
        O365SocialNetwork.Code := Code;
        O365SocialNetwork.Name := CopyStr(Name, 1, MaxStrLen(O365SocialNetwork.Name));
        O365SocialNetwork.Validate("Media Resources Ref", MediaResourcesMgt.InsertBLOBFromFile(FilePath, FileName));
        O365SocialNetwork.Insert();
    end;
}
#endif
