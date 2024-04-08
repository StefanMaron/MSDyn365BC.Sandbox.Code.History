codeunit 139013 "Mail Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [INT] [Mail]
        Initialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryUtility: Codeunit "Library - Utility";
        ActiveDirectoryMockEvents: Codeunit "Active Directory Mock Events";
        [RunOnClient]
        OutlookMessageMock: DotNet OutlookMessageMock;
        [RunOnClient]
        OutlookMessageFactoryMock: DotNet OutlookMessageFactoryMock;
        Initialized: Boolean;
        LongPasswordErr: Label 'Long password was set or get incorrect.';

    [Test]
    [Scope('OnPrem')]
    procedure OpenNewMessageTest()
    var
        Mail: Codeunit Mail;
        ToAddress: Text;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        ToAddress := 'none@home.local';

        Mail.OpenNewMessage(ToAddress);
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;

        Assert.IsTrue(OutlookMessageMock.SendWasCalled, 'Send was not called');
        Assert.IsTrue(OutlookMessageMock.ShowNewMailDialogOnSend, 'Show new message dialog was not set');
        Assert.AreEqual(ToAddress, OutlookMessageMock.Recipients, 'Recipients list differ from expetect');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure NewMessageTest()
    var
        Mail: Codeunit Mail;
        ToAddress: Text;
        CcAddresses: Text;
        BccAddresses: Text;
        Subject: Text;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        ToAddress := 'none@home.local';
        CcAddresses := 'none1@home.local';
        BccAddresses := 'none2@home.local';
        Subject := 'nosubject';

        Mail.NewMessage(ToAddress, CcAddresses, BccAddresses, Subject, 'NoBody', 'C:\Filename.etx', false);
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;

        Assert.IsTrue(OutlookMessageMock.SendWasCalled, 'Send was not called');
        Assert.IsFalse(OutlookMessageMock.ShowNewMailDialogOnSend, 'Show new message dialog was set');
        Assert.AreEqual(ToAddress, OutlookMessageMock.Recipients, 'Recipients list differ from expected');
        Assert.AreEqual(CcAddresses, OutlookMessageMock.CarbonCopyRecipients, 'CC Recipients list differ from expected');
        Assert.AreEqual(BccAddresses, OutlookMessageMock.BlindCarbonCopyRecipients, 'BCC Recipients list differ from expected');
        Assert.AreEqual(Subject, OutlookMessageMock.Subject, 'Subject differ from expected');
        Assert.AreEqual(6, OutlookMessageMock.Body.Length, 'Unexpected length of body');
        Assert.AreEqual(1, OutlookMessageMock.AttachmentFileNames.Count, 'Unexpected count of attachments');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AddBodyLineTest()
    var
        Mail: Codeunit Mail;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        Mail.AddBodyline('NewBodyLine1');
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;
        Assert.AreEqual(12, OutlookMessageMock.Body.Length, 'Unexpected body length');

        Mail.AddBodyline('NewBodyLine2');
        Assert.AreEqual(24, OutlookMessageMock.Body.Length, 'Unexpected body length');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetDescNoDataTest()
    var
        Mail: Codeunit Mail;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        Mail.Send();
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;

        Assert.IsTrue(OutlookMessageMock.SendWasCalled, 'Send was not called');
        Assert.AreEqual('', Mail.GetErrorDesc(), 'Unexpected error details');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateEmailTest()
    var
        CommunicationMethod: Record "Communication Method";
        Mail: Codeunit Mail;
        EMail: Text[80];
        Success: Boolean;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        EMail := 'none@home.local';
        if not CommunicationMethod.Get() then begin
            CommunicationMethod.Init();
            CommunicationMethod."E-Mail" := EMail;
            CommunicationMethod.Insert
        end else
            EMail := CommunicationMethod."E-Mail";

        Success := Mail.ValidateEmail(CommunicationMethod, EMail);
        Assert.IsTrue(Success, 'Invalid email');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateEmailFailTest()
    var
        CommunicationMethod: Record "Communication Method";
        Mail: Codeunit Mail;
        EMail: Text[80];
        Success: Boolean;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        EMail := 'none@home.fail.local';
        with CommunicationMethod do begin
            SetRange("E-Mail", CopyStr("E-Mail", 1, MaxStrLen("E-Mail")));
            if not IsEmpty() then
                DeleteAll();
        end;

        Success := Mail.ValidateEmail(CommunicationMethod, EMail);
        Assert.IsFalse(Success, 'E-mail is valid');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateNewMessageClearsAttachments()
    var
        Mail: Codeunit Mail;
        FileManagement: Codeunit "File Management";
        TmpFileName1: Text;
        TmpFileName2: Text;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        TmpFileName1 := FileManagement.ServerTempFileName('');
        Mail.NewMessage('none@home.inside1', '', '', 'Test', 'test1', TmpFileName1, false);
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;
        Assert.AreEqual(1, OutlookMessageMock.AttachmentFileNames.Count,
          'Unexpected count of attachments after calling new message');

        TmpFileName2 := FileManagement.ServerTempFileName('');
        Mail.NewMessage('none@home.inside2', '', '', 'Test', 'test2', TmpFileName2, false);
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;
        Assert.AreEqual(1, OutlookMessageMock.AttachmentFileNames.Count,
          'Unexpected count of attachments when calling new message again');

        Mail.NewMessage('none@home.inside3', '', '', 'Test', 'test3', '', false);
        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;
        Assert.AreEqual(0, OutlookMessageMock.AttachmentFileNames.Count,
          'Unexpected count of attachments after calling new message without attachmennt');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ValidateMutipleAttachedFile()
    var
        Mail: Codeunit Mail;
        FileManagement: Codeunit "File Management";
        TmpFileName: Text;
        Index: Integer;
        "Count": Integer;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        Mail.CreateMessage('none@home.inside1', '', '', 'Test', 'test1', false, false);
        Count := LibraryRandom.RandIntInRange(2, 5);
        for Index := 1 to Count do begin
            TmpFileName := FileManagement.ServerTempFileName('');
            Mail.AttachFile(TmpFileName);
        end;

        OutlookMessageMock := OutlookMessageFactoryMock.LastCreatedOutlookMessageMock;
        Assert.AreEqual(Count, OutlookMessageMock.AttachmentFileNames.Count,
          'Unexpected count of attachments after calling Attach File several times');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectAddressesTest()
    var
        CommunicationMethod: Record "Communication Method";
        Contact: Record Contact;
        Mail: Codeunit Mail;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        if not Contact.FindFirst() then
            Assert.Fail('One or more contacts are required to run this test');

        Mail.CollectAddresses(Contact."No.", CommunicationMethod, false);
        Assert.IsTrue(CommunicationMethod.Count > 0, 'Expected to find at least one address');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectAddressesWithNoContactTest()
    var
        CommunicationMethod: Record "Communication Method";
        Contact: Record Contact;
        Mail: Codeunit Mail;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        if Contact.Get('CTWRONG01') then
            Assert.Fail('Unexpected contact found');

        Mail.CollectAddresses('CTWRONG01', CommunicationMethod, false);
        Assert.IsTrue(CommunicationMethod.Count = 0, 'Expected not to find addresses');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectAddressesWithAlternativeAddressTest()
    var
        CommunicationMethod: Record "Communication Method";
        Contact: Record Contact;
        ContactAltAddress: Record "Contact Alt. Address";
        ContactAltAddrDateRange: Record "Contact Alt. Addr. Date Range";
        Mail: Codeunit Mail;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        if not Contact.FindFirst() then
            CreateDefaultContact;

        with ContactAltAddress do begin
            SetRange("Contact No.", Contact."No.");
            if not IsEmpty() then
                DeleteAll();

            Reset();
            Init();
            Code := 'ACODE1';
            "Contact No." := Contact."No.";
            "E-Mail" := 'someothertemporaryemail@domain.local';
            Insert();
        end;

        with ContactAltAddrDateRange do begin
            SetRange("Contact No.", Contact."No.");
            if not IsEmpty() then
                DeleteAll();

            Reset();
            Init();
            "Contact No." := Contact."No.";
            "Starting Date" := CalcDate('<-3D>', Today);
            "Contact Alt. Address Code" := 'ACODE1';
            "Ending Date" := Today;
            Insert();
        end;

        Mail.CollectAddresses(Contact."No.", CommunicationMethod, false);
        Assert.IsTrue(CommunicationMethod.Count > 1, 'Expected to find at least two address');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectAddressesWithCompanyTest()
    var
        CommunicationMethod: Record "Communication Method";
        Contact: Record Contact;
        Mail: Codeunit Mail;
        FirstAddress: Text;
    begin
        LibraryLowerPermissions.SetO365Setup();
        Initialize();

        Contact.SetRange(Type, Contact.Type::Person);
        Contact.SetFilter("Company No.", '<>""');
        if not Contact.FindFirst() then
            CreateDefaultContact;

        // Ensure contact has different address from company
        Contact."E-Mail" := 'thisisaspecialemail@somewherespecial.local';
        Contact.Modify();

        Mail.CollectAddresses(Contact."No.", CommunicationMethod, false);
        Assert.IsTrue(CommunicationMethod.Count > 1, 'Expected to find more than 1 items');

        CommunicationMethod.Find('-');
        FirstAddress := CommunicationMethod."E-Mail";
        while CommunicationMethod.Next() <> 0 do begin
            if CommunicationMethod."E-Mail" <> FirstAddress then
                exit; // Success
        end;

        Assert.Fail('Expected find more than one email address');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectUserEmailAddressesRemovesDublicatesTest()
    var
        User: Record User;
        UserSetup: Record "User Setup";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        Mail: Codeunit Mail;
        OriginalCount: Integer;
    begin
        LibraryLowerPermissions.SetOutsideO365Scope();
        UserSetup.SetRange("User ID", UserId);
        if UserSetup.FindFirst() then begin
            UserSetup."E-Mail" := '';
            UserSetup.Modify();
        end;

        User.SetRange("User Name", UserId);
        if not User.FindFirst() then begin
            User.Init();
            User."User Security ID" := CreateGuid();
            User."User Name" := UserId;
            User.Insert();
        end;
        User."Authentication Email" := '';
        User.Modify();

        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        OriginalCount := TempNameValueBuffer.Count();

        if not UserSetup.FindFirst() then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId;
            UserSetup.Insert();
        end;
        UserSetup."E-Mail" := Format(LibraryRandom.RandInt(1000)) + 'test1@mail.internal';
        UserSetup.Modify();
        TempNameValueBuffer.DeleteAll();
        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        Assert.AreEqual(OriginalCount + 1, TempNameValueBuffer.Count, 'Expected 1 email addresses to be added');

        User."Authentication Email" := UserSetup."E-Mail";
        User.Modify();
        TempNameValueBuffer.DeleteAll();
        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        Assert.AreEqual(OriginalCount + 1, TempNameValueBuffer.Count, 'Expected no email addresses to be added');

        User."Authentication Email" := Format(LibraryRandom.RandInt(1000)) + 'test1-1@mail.internal';
        User.Modify();
        TempNameValueBuffer.DeleteAll();
        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        Assert.AreEqual(OriginalCount + 2, TempNameValueBuffer.Count, 'Expected 1 email addresses to be added');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectUserEmailAddressesUserSetupEmailTest()
    var
        UserSetup: Record "User Setup";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        Mail: Codeunit Mail;
        OriginalCount: Integer;
    begin
        LibraryLowerPermissions.SetO365Setup();
        UserSetup.SetRange("User ID", UserId);
        if UserSetup.FindFirst() then begin
            UserSetup."E-Mail" := '';
            UserSetup.Modify();
        end;

        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        OriginalCount := TempNameValueBuffer.Count();

        if not UserSetup.FindFirst() then begin
            UserSetup.Init();
            UserSetup."User ID" := UserId;
            UserSetup.Insert();
        end;
        UserSetup."E-Mail" := Format(LibraryRandom.RandInt(1000)) + 'test2@mail.internal';
        UserSetup.Modify();

        TempNameValueBuffer.DeleteAll();
        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        Assert.AreEqual(OriginalCount + 1, TempNameValueBuffer.Count, 'Expected 1 email addresses to be added');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CollectUserEmailAddressesUserAuthenticationEmailTest()
    var
        User: Record User;
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        Mail: Codeunit Mail;
        OriginalCount: Integer;
    begin
        LibraryLowerPermissions.SetOutsideO365Scope();
        User.SetRange("User Name", UserId);
        if not User.FindFirst() then begin
            User.Init();
            User."User Security ID" := CreateGuid();
            User."User Name" := UserId;
            User.Insert();
        end;
        User."Authentication Email" := '';
        User.Modify();

        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        OriginalCount := TempNameValueBuffer.Count();

        // Test smtp mail setup address with @
        User."Authentication Email" := Format(LibraryRandom.RandInt(1000)) + 'test3@mail.internal';
        User.Modify();

        TempNameValueBuffer.DeleteAll();
        Mail.CollectCurrentUserEmailAddresses(TempNameValueBuffer);
        Assert.AreEqual(OriginalCount + 1, TempNameValueBuffer.Count, 'Expected 1 email addresses to be added');
    end;
    
    local procedure CreateDefaultContact()
    var
        Contact: Record Contact;
    begin
        with Contact do begin
            Init();
            "No." := 'CNTC001';
            Type := Type::Company;
            Name := 'Default contact company name';
            Address := 'Default Contact Address 1';
            "E-Mail" := 'defaultcompany@email.invaliddomain';
            "Search E-Mail" := 'defaultcompany@email.invaliddomain';
            Insert();

            Init();
            "No." := 'CNTP001';
            Type := Type::Person;
            "Company No." := 'CNTC001';
            Name := 'Default contact name';
            Address := 'Default Contact Address 1';
            "E-Mail" := 'default@email.invaliddomain';
            "Search E-Mail" := 'default@email.invaliddomain';
            Insert();
        end;
    end;

    local procedure Initialize()
    var
        OutlookMessageFactory: Codeunit "Outlook Message Factory";
    begin
        BindActiveDirectoryMockEvents;
        if Initialized then
            exit;
        Initialized := true;
        OutlookMessageFactoryMock := OutlookMessageFactoryMock.OutlookMessageFactoryMock;
        OutlookMessageFactory.SetOutlookMessageFactory(OutlookMessageFactoryMock);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DisableEncryption()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        // a teardown as the encryption should be disabled in the end
        LibraryLowerPermissions.SetO365Setup();
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);
    end;

    local procedure BindActiveDirectoryMockEvents()
    begin
        if ActiveDirectoryMockEvents.Enabled then
            exit;
        BindSubscription(ActiveDirectoryMockEvents);
        ActiveDirectoryMockEvents.Enable;
    end;
}

