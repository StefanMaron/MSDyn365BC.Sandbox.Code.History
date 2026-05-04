var WelcomeWizardAddIn = function () {
    var notifyError = function(error,description) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ErrorOccurred', [error, description]);
    };
    return {
        notifyError: notifyError
    };
}();

var roleCenterTitle;
var roleCenterDesc;

function Initialize(titletxt, subtitletxt, explanationtxt, intro, introDescription, getStarted, getStartedDescription, getHelp, getHelpDescription, roleCenters, roleCentersDescription, roleCenter, legalDescription) {
    DrawCanvas();
    DrawLayout(titletxt, subtitletxt, explanationtxt, intro, introDescription, getStarted, getStartedDescription, getHelp, getHelpDescription, roleCenters, roleCentersDescription, roleCenter, legalDescription);
}


function DrawCanvas()
{
    document.getElementById("controlAddIn").innerHTML = "";

    var canvas = document.createElement('div');
    canvas.className = "mainCanvas";
    canvas.id = "mainCanvas";
    document.getElementById("controlAddIn").appendChild(canvas);
}

function DrawLayout(titletxt, subtitletxt, explanationtxt, intro, introDescription, getStarted, getStartedDescripion, getHelp, getHelpDescription, roleCenters, roleCentersDescription, roleCenter, legalDescription)
{
    roleCenterTitle = roleCenters;
    roleCenterDesc = roleCentersDescription;
    var canvas = document.getElementById("mainCanvas");

    var container = document.createElement('div');
    container.className = "container";
    container.id = "welcomeContainer";
    
    var bottomBorder = document.createElement('div');
    bottomBorder.className = "sectionborder";

    var welcomeDiv = document.createElement('div');
    welcomeDiv.id = "welcomeDivTag";
    welcomeDiv.className = "welcomediv";

    var title = document.createElement('div');
    title.className = "title titlefont";
    var t = document.createTextNode(titletxt);
    title.appendChild(t);

    var br = document.createElement('br');

    var subtitle = document.createElement('div');
    subtitle.className = "subtitle brandPrimary titlefont";
    t = document.createTextNode(subtitletxt);
    subtitle.appendChild(t);

    var explanationdiv = document.createElement('div');
    explanationdiv.id = "expDiv";

    var explanationdesc = document.createElement('div');
    explanationdesc.className = "explanation brandSecondary";
    t = document.createTextNode(explanationtxt);
    explanationdesc.appendChild(t);


    welcomeDiv.appendChild(title);
    welcomeDiv.appendChild(br);
    welcomeDiv.appendChild(subtitle);
    explanationdiv.appendChild(explanationdesc);
    welcomeDiv.appendChild(explanationdiv);

    var welcomeimageDiv = document.createElement('div');
    welcomeimageDiv.className = "welcomeimagediv";

    var imageDiv = document.createElement('div');
    var welcomeImg = document.createElement("img");
    welcomeImg.className = "welcomeimage";
    welcomeImg.id = "welcomePic";
    welcomeImg.alt = "";
    var imageUrl = Microsoft.Dynamics.NAV.GetImageResource('01_welcome.png');
    welcomeImg.src = imageUrl;

    imageDiv.appendChild(welcomeImg);
    welcomeimageDiv.appendChild(imageDiv);

    bottomBorder.appendChild(welcomeDiv);
    bottomBorder.appendChild(welcomeimageDiv);

    container.appendChild(bottomBorder);

    var links = document.createElement('div');
    links.className = "links";
    links.id = "linksDiv";
    
    tile1 = document.createElement('button');
    tile1.className = "tile tilemarginright button";
    tile1.id = "tile1Button";

    var tile1Description = document.createElement('div');
    tile1Description.className = "tileDescription";
    tile1Description.id = "tileDescription1";
    t = document.createTextNode(intro);
    tile1Description.appendChild(t);

    var tile1SubDescription = document.createElement('div');
    tile1SubDescription.className = "segoeRegularfont brandSecondary";
    tile1SubDescription.id = "tileSubDescription1";
    t = document.createTextNode(introDescription);
    tile1SubDescription.appendChild(t);

    var tile1Img = document.createElement("img");
    tile1Img.id = "introductionImg";
    tile1Img.alt = "";
    imageUrl = Microsoft.Dynamics.NAV.GetImageResource('02_introduction.png');
    tile1Img.src = imageUrl;

    tile1.appendChild(tile1Description);
    tile1.appendChild(tile1SubDescription);
    tile1.appendChild(tile1Img);

    tile2 = document.createElement('button');
    tile2.className = "tile tilemarginright button";
    tile2.id = "tile2Button";

    var tile2Description = document.createElement('div');
    tile2Description.className = "tileDescription";
    tile2Description.id = "tileDescription2";
    t = document.createTextNode(getStarted);
    tile2Description.appendChild(t);

    var tile2SubDescription = document.createElement('div');
    tile2SubDescription.className = "segoeRegularfont brandSecondary";
    tile2SubDescription.id = "tileSubDescription2";
    t = document.createTextNode(getStartedDescripion);
    tile2SubDescription.appendChild(t);

    var tile2Img = document.createElement("img");
    tile2Img.id = "outlookImg";
    tile2Img.alt = "";
    imageUrl = Microsoft.Dynamics.NAV.GetImageResource('03_outlook.png');
    tile2Img.src = imageUrl;

    tile2.appendChild(tile2Description);
    tile2.appendChild(tile2SubDescription);
    tile2.appendChild(tile2Img);

    tile3 = document.createElement('button');
    tile3.className = "tile tilemarginright button";
    tile3.id = "tile3Button";

    var tile3Description = document.createElement('div');
    tile3Description.className = "tileDescription";
    tile3Description.id = "tileDescription3";
    t = document.createTextNode(getHelp);
    tile3Description.appendChild(t);

    var tile3SubDescription = document.createElement('div');
    tile3SubDescription.className = "segoeRegularfont tooltip brandSecondary";
    tile3SubDescription.id = "tileSubDescription3";
    tile3SubDescriptionText = getHelpDescription.length > 36 ? getHelpDescription.substring(0,36) + "..." : getHelpDescription;
    t = document.createTextNode(tile3SubDescriptionText);
    tile3SubDescription.appendChild(t);
    var span = document.createElement('span');
    span.className = "tooltiptext";
    span.appendChild(document.createTextNode(getHelpDescription));

    var tile3Img = document.createElement("img");
    tile3Img.id = "extensionsImg";
    tile3Img.alt = "";
    imageUrl = Microsoft.Dynamics.NAV.GetImageResource('04_extensions.png');
    tile3Img.src = imageUrl;

    tile3.appendChild(tile3Description);
    tile3.appendChild(tile3SubDescription);
    tile3.appendChild(tile3Img);

    tile4 = document.createElement('div');
    tile4.className = "tile";
    tile4.id = 'tile4';

    var button = CreateRoleCenterSection();

    tile4.appendChild(button);
    var roleCenterDiv = CreateRoleCenterDiv(roleCenter);
    tile4.appendChild(roleCenterDiv);

    links.appendChild(tile1);
    links.appendChild(tile2);
    links.appendChild(tile3);

    container.appendChild(links);

    links = document.createElement('div');
    links.id = "thumbnailLinksDiv"
    links.className = "links";

    var legalDescriptionDiv = document.createElement('div');
    legalDescriptionDiv.id = 'legalDescriptionDiv';
    legalDescriptionDiv.className = "legalDescription";
    var legalDiv = document.createElement('div');
    legalDiv.className = "segoeRegularfont brandSecondary legalDescriptionHeight";
    legalDiv.id = 'legalDiv';
    t = document.createTextNode(legalDescription);
    legalDiv.appendChild(t);

    legalDescriptionDiv.appendChild(legalDiv);

    links.appendChild(legalDescriptionDiv);

    container.appendChild(links);

    canvas.appendChild(container);

    $('#welcomeContainer').attr('role', 'dialog');
    $('#welcomeContainer').attr('aria-describedby', 'welcomeDivTag');
    $('#welcomePic').attr('role', 'presentation');
    $('#tile1Button').attr('aria-labelledby', 'tileDescription1 tileSubDescription1');
    $('#tile2Button').attr('aria-labelledby', 'tileDescription2 tileSubDescription2');
    $('#tile3Button').attr('aria-labelledby', 'tileDescription3 tileSubDescription3');
    $('#legalDescriptionDiv').attr('aria-labelledby', 'legalDiv'); 
    
    $("#tile1Button").click(function(){ThumbnailClick(1);});
    $("#tile2Button").click(function(){ThumbnailClick(2);});
    $("#tile3Button").click(function(){ThumbnailClick(3);});
}

function ThumbnailClick(id)
{ 
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ThumbnailClicked', [id]);
}

function RoleCenterClick()
{ 
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('RoleCenterClicked', [1]);
}

function UpdateProfileId(profileId)
{ 
}

function CreateRoleCenterSpan()
{
    var checkboxSpan = document.createElement('span');
    checkboxSpan.className = "checkbox";
    var checkboxImg = document.createElement('img');
    checkboxImg.id = "checkboxImg";
    checkboxImg.alt = "";
    var imageUrl = Microsoft.Dynamics.NAV.GetImageResource('GoChecked.png');
    checkboxImg.src = imageUrl;
    checkboxSpan.appendChild(checkboxImg);
    return checkboxSpan;
}

function CreateRoleCenterSection()
{

    var button = document.createElement('button');
    button.className = "button";
    button.id = "tile4Button";

    var tile4Description = document.createElement('div');
    tile4Description.className = "tileDescription";
    tile4Description.id = "tileDescription4";
    t = document.createTextNode(roleCenterTitle);
    tile4Description.appendChild(t);

    var tile4SubDescription = document.createElement('div');
    tile4SubDescription.className = "segoeRegularfont brandSecondary";
    tile4SubDescription.id = "tileSubDescription4";
    t = document.createTextNode(roleCenterDesc);
    tile4SubDescription.appendChild(t);

    var tile4Img = document.createElement("img");
    tile4Img.id = "roleCenterImg";
    tile4Img.alt = "";
    imageUrl = Microsoft.Dynamics.NAV.GetImageResource('05_rolecenter.png');
    tile4Img.src = imageUrl;

    button.appendChild(tile4Description);
    button.appendChild(tile4SubDescription);
    button.appendChild(tile4Img);
    return button;
}

function CreateRoleCenterDiv(roleCenter)
{
    var roleCentDiv = document.createElement('div');
    roleCentDiv.id = 'roleCenterName';
    roleCentDiv.className = "segoeRegularfont brandPrimary truncate";
    
    var checkboxSpan = CreateRoleCenterSpan();
    roleCentDiv.appendChild(checkboxSpan);
    
    t = document.createTextNode('  ' + roleCenter);
    roleCentDiv.appendChild(t);
    return roleCentDiv;
}

// SIG // Begin signature block
// SIG // MIInbwYJKoZIhvcNAQcCoIInYDCCJ1wCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // vyBTZ+HWNnSPHYQLjLrjfwD5l47RY9BkoKdovL/30cOg
// SIG // ggzJMIIGBDCCA+ygAwIBAgITMwAAAhz6zcWb6C9+xAAA
// SIG // AAACHDANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJV
// SIG // UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5n
// SIG // IFBDQSAyMDI0MB4XDTI2MDQxNjE4NTk0MVoXDTI3MDQx
// SIG // NTE4NTk0MVowdDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
// SIG // Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
// SIG // BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEeMBwG
// SIG // A1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjAN
// SIG // BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1bGX4Dip
// SIG // jN9Rz36FjqDRIsNEpQoiMVDAtCPTTFm7nCjsP3vZT6AK
// SIG // HoUFbukhuuVeBD862LJwZxTzaIuPx6DnY4c9apKxLeCO
// SIG // rRHMV1OqDnmPcxr3gv94gXroS2MTNzPz5HFKHmxfjXnZ
// SIG // 5vDpHUj6A7vIplYhz0Kv/AkFLtFkUeKxPnTEX66Van5j
// SIG // Ytqlgl/eE+DLHqYoxlZMBP/7SYNK8gImHR09+C0p5Rv0
// SIG // UgWZkERlmeYPI6pyo0T2q0qjH7dYL47lE1YLVjWX4HCx
// SIG // UiuVmtJsq6vDj3IExhrEYLp/rZ0kviMQ08VbADx9Ts7z
// SIG // 48KJoLgcoVHvznL1DdA+Vpqe8QIDAQABo4IBqjCCAaYw
// SIG // DgYDVR0PAQH/BAQDAgeAMB8GA1UdJQQYMBYGCisGAQQB
// SIG // gjdMCAEGCCsGAQUFBwMDMB0GA1UdDgQWBBTaB+2tmA4z
// SIG // ksKZKegx3JlEuyftMjBUBgNVHREETTBLpEkwRzEtMCsG
// SIG // A1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
// SIG // cyBMaW1pdGVkMRYwFAYDVQQFEw0yMzAwMTIrNTA3NTY5
// SIG // MB8GA1UdIwQYMBaAFH9ZP1Qh2q1P7wXl5qPXLQaUEggx
// SIG // MGAGA1UdHwRZMFcwVaBToFGGT2h0dHA6Ly93d3cubWlj
// SIG // cm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
// SIG // MENvZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyNC5jcmww
// SIG // bQYIKwYBBQUHAQEEYTBfMF0GCCsGAQUFBzAChlFodHRw
// SIG // Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRz
// SIG // L01pY3Jvc29mdCUyMENvZGUlMjBTaWduaW5nJTIwUENB
// SIG // JTIwMjAyNC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
// SIG // 9w0BAQsFAAOCAgEAFJxKoWkV3tE94SCY73UBKxJKwP+2
// SIG // wco5+reSAKzg5JEY85GMLSjHNsmI9qrmjay7rVsNmGXJ
// SIG // 4Cj8tW+9WMgyUE8uDQ0cGkofU8ObYa5NzZnD6wB4mub7
// SIG // XASdQoLSiu5kGyHENtnfzd/Nd2sggwxXsLtfo7GZl/q/
// SIG // 2kxKmjjOE1cVbUUpLgsvJwFyrgoTii4v8wOF7h/IhGKi
// SIG // LI9mKDWnksVZnhohEV6SnaN3Q5mItJDucNg/FUuHN/vY
// SIG // eoBJWAWgAIP3WBKwYNu6k9779M0QyYSbn7wjcpQPEu//
// SIG // vB+RPz1eXJ4Op2vVVf8PTld6rrjQ+s3RmthF9/BpaedB
// SIG // fQCEJN6dsV5nL6Kw3jOFye1JVmAYuoPNCdUkjkJyJwmB
// SIG // RJrH1DZ9/tQGkySkiS/N6rigK02nNqSobtGM88686Oh6
// SIG // 7EYkCs6Z0QW9f3TGuj94c++V2zEQXLTbBYWQtO1gpoxM
// SIG // XS4Nnh1ubldE2PA+fusKMyX+7xd/lh5GDzvOWfgQulOB
// SIG // ZDW2DcnGfXBOI9bV0Xcgwn5penNB1jx4zVQzm67/ZSrd
// SIG // 6lKhaV9/FQqlQsjTjtVHF30IlYycN9lNllCmY7f53iSh
// SIG // xAbJvZBbC7ls5EOd/qnGkmsrZrAp5NoDoJa5Q+Xd5Csr
// SIG // 7wMPq85tJU/Ct/D+jy8X2UB4buFvHVewL/DdmZgwgga9
// SIG // MIIEpaADAgECAhMzAAAAOTu2Nxm/Bh1nAAAAAAA5MA0G
// SIG // CSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
// SIG // Y2F0ZSBBdXRob3JpdHkgMjAxMTAeFw0yNDA4MDgyMDU0
// SIG // MThaFw0zNjAzMjIyMjEzMDRaMFcxCzAJBgNVBAYTAlVT
// SIG // MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
// SIG // KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcg
// SIG // UENBIDIwMjQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
// SIG // ggIKAoICAQDYAZwe4zjHqpUWBzWtuub+CGPXx/EyoXph
// SIG // 3zyDXtYKS2ld3YYN9uFsB9Oi3B26Z7AbpAgzYra8qNHb
// SIG // UvxFuiP8hC/2y0mPISqW30LlrrAT6/ams2HA8Qlv6p42
// SIG // +SbCNbPGzToN21QE70FS+LXH9N2k8nLM/EHgnTNJf8h0
// SIG // TmyfUKmszNa+lTxDieyy/rhBG+98OkArobPPWtbr9c3q
// SIG // zmDJ7J3kUcAm6cltdSHIIFNHESgw6taY1ScyGyBevqIl
// SIG // 120XjrIHiPM7tRckHytH1ZGsmvEplR0P7Tn9t5meFvZN
// SIG // EYttkFvad1IEguTlA5LSscXAphi+rVy3zhklhyCFeGK0
// SIG // yU0+jzbcuURKIxybmRwK5BfVZx0xEVqE4wM3yN5D/uW+
// SIG // GpVHYYAGe7bTrtW1Z13x2qj2Jdqz7NtI4tNyzlVrIf62
// SIG // nYBNe3rOYS/repVdHlR61YbLLETlibs9jFzAre4sO5RT
// SIG // xvS1yho7JqJ59oKLRnRyLhIOSZyTCVZosXeS0ZZJoGEW
// SIG // Ss4cUgsMqBiKtD4WgO2PlT3LeaQh5Io3CCA5tJ5ZCvtC
// SIG // snqaJXKhptE/xmEETIRyZRjjplUKKd+sFFVGJJVMvvrw
// SIG // 1nhIBKOLO4cTepiG39jEiEP4iHzGYCcQuvaLpDFFwqzg
// SIG // t0pBP8SJIKX5dtjDNYrZGd+ZzV5DKJVNZQIDAQABo4IB
// SIG // TjCCAUowDgYDVR0PAQH/BAQDAgGGMBAGCSsGAQQBgjcV
// SIG // AQQDAgEAMB0GA1UdDgQWBBR/WT9UIdqtT+8F5eaj1y0G
// SIG // lBIIMTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAP
// SIG // BgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIx
// SIG // kEO5FAVO4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuG
// SIG // SWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3Js
// SIG // L3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8w
// SIG // M18yMi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUF
// SIG // BzAChkJodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
// SIG // L2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
// SIG // Mi5jcnQwDQYJKoZIhvcNAQEMBQADggIBABSUHzgoT+6J
// SIG // 5+nyyDCq0pTdVmCsAxYAHXcpjlDtxazPHewf1v4kOg8V
// SIG // 7A5+w+VuMDMGHi8rLXBKn5I8+DVEUYGs8jLuckc0IeC6
// SIG // owOLUrU3CYdaKRMaO55+T7jwWJ27tPkx0rlR03tFU0z1
// SIG // YYpcv6Yhaw6N2sUPT+AvjpecnrftoE33pCAkucUvnGH0
// SIG // iL4J9CZLFQVTGFSOUBbv6oZy4bBBRFMxvH779IY4JDvp
// SIG // ZKVfbcuhpDeL3Z3e8mukOmkfct+GojNapsWsQYujlJ8j
// SIG // Zen5Lrp/3YkxZ2Ay06aTpK/5oOVknwog1TDQsbY+MDyg
// SIG // uTph5tQ0CLfzDaJG2x91BrBT9UG87C6HLkqiwrx9PSKN
// SIG // 3wz05rHEfWO+RuKl+0U1/AHQT6NCOjhKI39/c7hWbdKj
// SIG // h5uuWFkBOvXGTNrnhNTAdOXTTYByvYExO8yryv34PAdq
// SIG // o1vPDE/1heVebr2RramvRUi9kWswKwPqwz7n+iRmM+B6
// SIG // YDGRweEurM1kimAb9FYrAs38YHlPnarl1vW3dGrmJTge
// SIG // fAz3DmCnXN0nveIPsS+KXBIWweeCToAJMGE7v/XS3h9q
// SIG // Q6niWQAAVQ1kUAml3zuS4MisCgi2F6YoK2WAo1EgXK/l
// SIG // XvDxVjIVU0JdL+KvCfwFJkDeVuJ9dNXGNi+AOxk0BtYd
// SIG // 9hxwL30BElj9MYIZ/jCCGfoCAQEwbjBXMQswCQYDVQQG
// SIG // EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWdu
// SIG // aW5nIFBDQSAyMDI0AhMzAAACHPrNxZvoL37EAAAAAAIc
// SIG // MA0GCWCGSAFlAwQCAQUAoIGuMBkGCSqGSIb3DQEJAzEM
// SIG // BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
// SIG // BgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCBNh76InfF4
// SIG // r0sZPyG1/HJTqPTzqVSyF85HF8/AtwayWDBCBgorBgEE
// SIG // AYI3AgEMMTQwMqAUgBIATQBpAGMAcgBvAHMAbwBmAHSh
// SIG // GoAYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqG
// SIG // SIb3DQEBAQUABIIBAJHKHoMJjTKxp4WxglYzONxSEZh6
// SIG // i9yqOWn5LN/CzW9EOiYG6XZ/LO2XUOAvSNiWwq7OAd4a
// SIG // TA+k8rbHdCGg8lr69r/K/ICMfYo7Jng6UEb72GoojYMF
// SIG // uVS0RmMCfMZxNQq6UEJBGR4viO2hHBgh5fNz0AE3cliu
// SIG // Tm8wuUcEv75fUYKsMqWcutoZ07ate8dDeeXitSDmLKRj
// SIG // PYRnzInCygKyikmnyuL4b65NGsZiD9H0vFjc/xAUZROm
// SIG // F60EnMWDmDWOangyHdX+jeFc2ixAO7PcuKqBN11ANim5
// SIG // wmodwgRxE3qWOmR2UDA4ljW/+cmVXB7fk5sEhNwdANuq
// SIG // ujiu9L+hghewMIIXrAYKKwYBBAGCNwMDATGCF5wwgheY
// SIG // BgkqhkiG9w0BBwKggheJMIIXhQIBAzEPMA0GCWCGSAFl
// SIG // AwQCAQUAMIIBWgYLKoZIhvcNAQkQAQSgggFJBIIBRTCC
// SIG // AUECAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEF
// SIG // AAQgKnCXYLfPoG/djPFTTuS+QzbXY/3NfoADgnR1U7mb
// SIG // ez0CBmnridMd/hgTMjAyNjA1MDMxMTA5MDguNDg3WjAE
// SIG // gAIB9KCB2aSB1jCB0zELMAkGA1UEBhMCVVMxEzARBgNV
// SIG // BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
// SIG // HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
// SIG // MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
// SIG // aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRT
// SIG // UyBFU046MkQxQS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1p
// SIG // Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghH+MIIH
// SIG // KDCCBRCgAwIBAgITMwAAAhLRCAY8yhhPqgABAAACEjAN
// SIG // BgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMDAeFw0yNTA4MTQxODQ4MTVaFw0yNjExMTMx
// SIG // ODQ4MTVaMIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYD
// SIG // VQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25z
// SIG // IExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
// SIG // TjoyRDFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAK9M06A5KVkLbGXp
// SIG // EtHFdKrg3SkkxpKL7wWmR9DgCBItDtwnDu+yYl/HOBKa
// SIG // vbomx1WWdVvy6LnxNe9r5EVzvkGDbVlqKxAidgHGUNdG
// SIG // 6QJbZIWTYl5VSfC90M4SoK165jJJtifv4PNVNtyT3DuM
// SIG // FxxH7aJ098KXf//d+q45sMTJuzZG7MoGyX/uAFQTDa+G
// SIG // jD0IQXe+qHdCjAelq78hBjjlNPPdzhbn0uRA3suJ+OFo
// SIG // GsSRNFZ79/zjr7jsOSqdSj6o42Cfi/csC7gTLXA3y6TU
// SIG // Dv4dXhRKDK24hDOu0znzZV38Ww8+DJbGLy4qMYHdl83s
// SIG // tUMa1dfoviclQyTIknvYCjrs6YkEBRNfQ1D4LIncoy08
// SIG // 1xIUlSwZUaK9HglX+4AukX5PDWN6ztrIIDi+/b1ORbgy
// SIG // k4f7CDrXFB3hwuNowRgfrX3SgtSjgUflJTfWjs4PJqVD
// SIG // SNhYKkL4q1T/aaW3jFH76dsAPb6Mk4kVrw4MwsaPMZSd
// SIG // Z7HGExyEK5pBfY/wmtCA5rfH7zp+uJ55SThlGGWBzAtZ
// SIG // dMbYJGExNRElKqpGsCpO4qm8XZy8snEvnUfs2sT7nTAy
// SIG // 60Bc/JYH8vaG5NA/Bwtnc4VqWDZ+YXZKDxM4AqkFDqfL
// SIG // 90I/7HeGp8rqXuSqApIwATj98oUkOFvWfg6yZ4TP627F
// SIG // wu6E79unAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUUgW5
// SIG // UsW+XGCmDsL3f1X6Fzn7t94wHwYDVR0jBBgwFoAUn6cV
// SIG // XQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKg
// SIG // UIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
// SIG // cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBD
// SIG // QSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
// SIG // BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
// SIG // LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0T
// SIG // AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
// SIG // BgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIB
// SIG // AF50gJJl+/UXO5cUtcDqM1ye1dKLuQ57VXDiaZSJA47x
// SIG // DfASEKYeFPoEji2blUXj/8/WHVIlJHD8C9TzNuOf5BF9
// SIG // RHoKcTXPBwwOoSgh4NACzRHLsZxjpYCi6JF31Hq9Q+YY
// SIG // lvDwATPUfp3orXk4D2mkZSRbxk2L6LXNLqhohEuYTEIS
// SIG // /ETRYaUvUXCFh7Z0BhJ63TlLwgIbOBXlYmsHJi0yr/tf
// SIG // O9HPzHkx4tEA3Xkfu/1oOKoZCdpNYhByXZmH/KyFdDUQ
// SIG // WXHUU03R3nt+Ulz+Z3jQnwJIwyLmcnEbneo8zywjS4jW
// SIG // MxlwbMMycoI+BHkjkU+8DL2hbinkQF6Fwt8MGL4CLCNc
// SIG // 59wxmOtuWPsmUovFDUjR7q4t+mb/WvkOLycA6WCt+ktE
// SIG // wdqX+8S4oh99p5O2Cu90YPfFun2diDbs2M2exoYL3335
// SIG // I+BFF4NRNBH32NaRKpG6Q0z+4fwwarc6D17MsNjFIfu8
// SIG // r1nKtgRmUrnGugmOl+IqDLnOT1qbJrzjpYuwETQOwG/J
// SIG // CnQnNoDQy2nIJbMHmRHPf1UAeoZbP2+ipN9p5MLhxMSp
// SIG // WnqElaygeVPcZadfnPCf+xiY+EcOwIkPLXKflpn8g/Cs
// SIG // V9kJSmw4uElI54Jb+Ote0fPmv3A1icmjLfNu/Vp+39sj
// SIG // HnTe5HxiEOUmY+ukXYXZWTqvMIIHcTCCBVmgAwIBAgIT
// SIG // MwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsF
// SIG // ADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMp
// SIG // TWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
// SIG // aXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMw
// SIG // MTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
// SIG // VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
// SIG // MDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
// SIG // AOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjK
// SIG // NVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
// SIG // hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ
// SIG // 3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2r
// SIG // rPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxqD89d
// SIG // 9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4x
// SIG // yDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3
// SIG // rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSWrAFKu75x
// SIG // qRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9
// SIG // fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PR
// SIG // c6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1D
// SIG // TsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC
// SIG // 4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTY
// SIG // uVD5C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqv
// SIG // UAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUe
// SIG // h17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TAS
// SIG // BgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQW
// SIG // BBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
// SIG // n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBR
// SIG // BgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
// SIG // cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2Nz
// SIG // L1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUF
// SIG // BwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
// SIG // A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
// SIG // IwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1Ud
// SIG // HwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
// SIG // LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1
// SIG // dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEww
// SIG // SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0
// SIG // LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAt
// SIG // MDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38
// SIG // Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEz
// SIG // tTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6
// SIG // U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
// SIG // y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jf
// SIG // ZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kp
// SIG // icO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbCHcNh
// SIG // cy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtP
// SIG // u4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4K
// SIG // WN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMB
// SIG // V0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvsh
// SIG // VGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFs
// SIG // c/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8
// SIG // vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgk
// SIG // NWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9
// SIG // vMvpe784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFx
// SIG // BmoQtB1VM1izoXBm8qGCA1kwggJBAgEBMIIBAaGB2aSB
// SIG // 1jCB0zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
// SIG // TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1p
// SIG // dGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MkQx
// SIG // QS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
// SIG // aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMV
// SIG // AOVRwa+IdNBDe41HUN90hPqm5P/AoIGDMIGApH4wfDEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcN
// SIG // AQELBQACBQDtoTx4MCIYDzIwMjYwNTAzMDMxNjA4WhgP
// SIG // MjAyNjA1MDQwMzE2MDhaMHcwPQYKKwYBBAGEWQoEATEv
// SIG // MC0wCgIFAO2hPHgCAQAwCgIBAAICKlMCAf8wBwIBAAIC
// SIG // E30wCgIFAO2ijfgCAQAwNgYKKwYBBAGEWQoEAjEoMCYw
// SIG // DAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQAC
// SIG // AwGGoDANBgkqhkiG9w0BAQsFAAOCAQEAKG9XIgLPRJ5J
// SIG // b38bI0bsZ9RF4MeDTnS3CsDu6/5tdELhsN3A5yuY8IVD
// SIG // VnTHrqyHuHds6FcJSYK7BVU1r/p72cljJZ5gxFPfL2kn
// SIG // 89yVdldDVeZJBV6Tx6YAHx7fvbBAnUrNEuTQQ9bOidNY
// SIG // JNp+ZLmKb2ccIXZ1rj4HdhFPu6ehnprBCupxUdAZwkGb
// SIG // jHpjahKHgAPYvlavXjH+82s+yT0z0g5viIc2Er1TTSkq
// SIG // maDceq/dHvNbqm4w6qXzx/Fymg/REwdUf5R5PW2uIfS4
// SIG // jCpUtKXJ/4Qn0l75TA07UZO8RYFNesBk4aNx1C2FbUBh
// SIG // XQuh9OiBpgraU4XdQrYwnjGCBA0wggQJAgEBMIGTMHwx
// SIG // CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
// SIG // MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
// SIG // b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
// SIG // c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAACEtEI
// SIG // BjzKGE+qAAEAAAISMA0GCWCGSAFlAwQCAQUAoIIBSjAa
// SIG // BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZI
// SIG // hvcNAQkEMSIEIEx5kJrhelpKAXmsZWmttkV4VEGigz5c
// SIG // 0Au3YTB4MbgXMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB
// SIG // 5DCBvQQgc/l+Rrzu1p4JJx+AWXmFPgcwS9ScuaCfMFZU
// SIG // zSMX2IMwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMAITMwAAAhLRCAY8yhhPqgABAAACEjAiBCB+
// SIG // tgtzsrCaS/iDcJCkmX4bjnSdko/YDmMqd+usv5s+bzAN
// SIG // BgkqhkiG9w0BAQsFAASCAgBR6u4Ip7/Auam6eU6BImW8
// SIG // zNfMsojXm9hAPG2NZwP93mCpaZFGc6IH82dIO6fBKlRI
// SIG // 1VHteUa4htqJ7ZYie4oABiCXrYR1aAbJ2offmV7DOjiL
// SIG // GV6w980H0aeP8Lu6XM7UDRzu9F++H/W78IcV1AaeyPkA
// SIG // pgdr/EpfAL1E4R8w/UbuLr7Ws6hYTK8M+EEW9Bv/HtfS
// SIG // B9vkctYH38+FphmY298fQzaiqccrBGnwrtu5voWspwgt
// SIG // TsWB8Ii9EDElNMHKV/DvDjhVz9yB8Sv8clENDjuyAF7P
// SIG // j8e/q2TVRXLYIsN9CTtGaiWufarRgb3F/1wr0A0uGx8w
// SIG // Qmr3xBK8AtrAxofu64mlzp1gsbWJ57v51tleyZrmZFKL
// SIG // gNRGjAoYODP/XtvUNYNwqlTeIJ/7RjsVmegUUOO5383D
// SIG // 2Ccdj/RuXVVXZTzVwV5tOH3AEjRnVxC1Tp7g/XnZrr6U
// SIG // Nf42GhHzKbONgyfxDPb2D6XS5M2MRyTihhClvgpAv7Q6
// SIG // K29VJhiufuOWZmUaRTZIq+YE3KaFKYw7j2p/GsOp3N9Y
// SIG // oUp8+5n0ixJziuicftSp/mk5X6hC8r2qDlWZRRm/7bvW
// SIG // lnOWOf+V2MqL8blreMg16pW3bL++aEIbz/1E2cmyl6Yi
// SIG // xM0rkffwvbK8benRZQoVCv8Rz15ePvds7pIH5fIBTixhSA==
// SIG // End signature block
