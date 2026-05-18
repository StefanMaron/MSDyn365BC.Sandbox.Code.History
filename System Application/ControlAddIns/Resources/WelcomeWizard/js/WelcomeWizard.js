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
// SIG // MIIoKAYJKoZIhvcNAQcCoIIoGTCCKBUCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // vyBTZ+HWNnSPHYQLjLrjfwD5l47RY9BkoKdovL/30cOg
// SIG // gg12MIIF9DCCA9ygAwIBAgITMwAABIVemewOWS/N1wAA
// SIG // AAAEhTANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBT
// SIG // aWduaW5nIFBDQSAyMDExMB4XDTI1MDYxOTE4MjEzN1oX
// SIG // DTI2MDYxNzE4MjEzN1owdDELMAkGA1UEBhMCVVMxEzAR
// SIG // BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
// SIG // bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
// SIG // bjEeMBwGA1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
// SIG // wEpIdXKb7lKn26sXpXuywkhxGplTQXxROLmNRZBrAHVB
// SIG // f7546RNXZwA/bzDqsuWTuPSC4T+I4j/z9j5/WqPuUw7S
// SIG // pnEPqWXc2xu7eN8kVyQt5170xkK6KHT4vVEkIvayPtIM
// SIG // Ll0SgSCOy/pN5DJCi5ha7FlI84F1Qi2GumR+wQgCwHCV
// SIG // mU8Fj6Ik+B6akISXGCwe6X3rQFQngRFWQ/IrSkOkAOfy
// SIG // 0EfvV+nZUo+FcbWuCZ6cb4Eq5I1ws/rZSeuwAWeedZcN
// SIG // t0VlNbsn4AnxBYQX4sj0dlko7JD5fWqeqq3/HzUNbBmL
// SIG // p9qeCXV8XlACn9YVWv900F47z04kVwpyTwIDAQABo4IB
// SIG // czCCAW8wHwYDVR0lBBgwFgYKKwYBBAGCN0wIAQYIKwYB
// SIG // BQUHAwMwHQYDVR0OBBYEFLgmchogri2BNGlO4+UxamNO
// SIG // ZJKNMEUGA1UdEQQ+MDykOjA4MR4wHAYDVQQLExVNaWNy
// SIG // b3NvZnQgQ29ycG9yYXRpb24xFjAUBgNVBAUTDTIzMDAx
// SIG // Mis1MDUzNTkwHwYDVR0jBBgwFoAUSG5k5VAF04KqFzc3
// SIG // IrVtqMp1ApUwVAYDVR0fBE0wSzBJoEegRYZDaHR0cDov
// SIG // L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWlj
// SIG // Q29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNybDBhBggr
// SIG // BgEFBQcBAQRVMFMwUQYIKwYBBQUHMAKGRWh0dHA6Ly93
// SIG // d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWlj
// SIG // Q29kU2lnUENBMjAxMV8yMDExLTA3LTA4LmNydDAMBgNV
// SIG // HRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4ICAQAo5qgK
// SIG // dgouLEx2XIvqpLRACrBZORzVRislkdqxRl7He3IIGdOB
// SIG // +VOEldHwC+nzhPXS77eCOxwRy4aRnROVIy8uDcS0xtmw
// SIG // wJHgFZsZndrillRisptWmqw8V379xgjeJkV/j5+HPqct
// SIG // 0v+ipLeXkgwCCLK8ysNyodkltYQsF1/5Nb+G/jR9RY5f
// SIG // ov8TybKVwhbmQeGguRS0+X4G0Sqp7FngHZ/A7K2EIU90
// SIG // Fy7ejb9/3TM7+xvwnaW3XKLpfBWJfrd3ZlzPkiApQt5d
// SIG // mntMDpTa0ONskBMnLj1OTqKi0/OY7Ge/uAmknHxSDZTu
// SIG // 5e2O6/8Wrqh20j0Na96CAvnu9ebNhtwpWWt8vfWmMdpZ
// SIG // 12HtbK3KyMfDQF01YosqV1Z/WRphJHzXHw4qhkMJJpec
// SIG // /Z5t6VogWevWnWgQWwBRI8iRuMtGu+m3pf+LAwlb2mcy
// SIG // zN0xW8VTvQUK42UbWyWW5At1wK6S6mUn8ed0rmHXXcT1
// SIG // /Kb3KhbhLvMHFHg9ObfcTWyeE7XQBAiZRItL7wcZZjOb
// SIG // cxV8tqmXqjzFx0kGKj4GfY70nGejcM5xQ9Pt95G88oTk
// SIG // s/1rhmwLuHB2RvICp5UFU+LgNg4nsfQzLNlh4qJDZJ2J
// SIG // S6FHll1tUKyS6ajvNky8ik2wTP6GRwHSHNJM6Ek66PW9
// SIG // /r459vNPQ9PkjjglWTCCB3owggVioAMCAQICCmEOkNIA
// SIG // AAAAAAMwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYT
// SIG // AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
// SIG // EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
// SIG // cG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290
// SIG // IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDExMB4XDTEx
// SIG // MDcwODIwNTkwOVoXDTI2MDcwODIxMDkwOVowfjELMAkG
// SIG // A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
// SIG // BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
// SIG // dCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0
// SIG // IENvZGUgU2lnbmluZyBQQ0EgMjAxMTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAKvw+nIQHC6t2G6q
// SIG // ghBNNLrytlghn0IbKmvpWlCquAY4GgRJun/DDB7dN2vG
// SIG // EtgL8DjCmQawyDnVARQxQtOJDXlkh36UYCRsr55JnOlo
// SIG // XtLfm1OyCizDr9mpK656Ca/XllnKYBoF6WZ26DJSJhIv
// SIG // 56sIUM+zRLdd2MQuA3WraPPLbfM6XKEW9Ea64DhkrG5k
// SIG // NXimoGMPLdNAk/jj3gcN1Vx5pUkp5w2+oBN3vpQ97/vj
// SIG // K1oQH01WKKJ6cuASOrdJXtjt7UORg9l7snuGG9k+sYxd
// SIG // 6IlPhBryoS9Z5JA7La4zWMW3Pv4y07MDPbGyr5I4ftKd
// SIG // gCz1TlaRITUlwzluZH9TupwPrRkjhMv0ugOGjfdf8NBS
// SIG // v4yUh7zAIXQlXxgotswnKDglmDlKNs98sZKuHCOnqWbs
// SIG // YR9q4ShJnV+I4iVd0yFLPlLEtVc/JAPw0XpbL9Uj43Bd
// SIG // D1FGd7P4AOG8rAKCX9vAFbO9G9RVS+c5oQ/pI0m8GLhE
// SIG // fEXkwcNyeuBy5yTfv0aZxe/CHFfbg43sTUkwp6uO3+xb
// SIG // n6/83bBm4sGXgXvt1u1L50kppxMopqd9Z4DmimJ4X7Iv
// SIG // hNdXnFy/dygo8e1twyiPLI9AN0/B4YVEicQJTMXUpUMv
// SIG // dJX3bvh4IFgsE11glZo+TzOE2rCIF96eTvSWsLxGoGyY
// SIG // 0uDWiIwLAgMBAAGjggHtMIIB6TAQBgkrBgEEAYI3FQEE
// SIG // AwIBADAdBgNVHQ4EFgQUSG5k5VAF04KqFzc3IrVtqMp1
// SIG // ApUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
// SIG // VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0j
// SIG // BBgwFoAUci06AjGQQ7kUBU7h6qfHMdEjiTQwWgYDVR0f
// SIG // BFMwUTBPoE2gS4ZJaHR0cDovL2NybC5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
// SIG // MjAxMV8yMDExXzAzXzIyLmNybDBeBggrBgEFBQcBAQRS
// SIG // MFAwTgYIKwYBBQUHMAKGQmh0dHA6Ly93d3cubWljcm9z
// SIG // b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0MjAx
// SIG // MV8yMDExXzAzXzIyLmNydDCBnwYDVR0gBIGXMIGUMIGR
// SIG // BgkrBgEEAYI3LgMwgYMwPwYIKwYBBQUHAgEWM2h0dHA6
// SIG // Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvZG9jcy9w
// SIG // cmltYXJ5Y3BzLmh0bTBABggrBgEFBQcCAjA0HjIgHQBM
// SIG // AGUAZwBhAGwAXwBwAG8AbABpAGMAeQBfAHMAdABhAHQA
// SIG // ZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEA
// SIG // Z/KGpZjgVHkaLtPYdGcimwuWEeFjkplCln3SeQyQwWVf
// SIG // Liw++MNy0W2D/r4/6ArKO79HqaPzadtjvyI1pZddZYSQ
// SIG // fYtGUFXYDJJ80hpLHPM8QotS0LD9a+M+By4pm+Y9G6XU
// SIG // tR13lDni6WTJRD14eiPzE32mkHSDjfTLJgJGKsKKELuk
// SIG // qQUMm+1o+mgulaAqPyprWEljHwlpblqYluSD9MCP80Yr
// SIG // 3vw70L01724lruWvJ+3Q3fMOr5kol5hNDj0L8giJ1h/D
// SIG // Mhji8MUtzluetEk5CsYKwsatruWy2dsViFFFWDgycSca
// SIG // f7H0J/jeLDogaZiyWYlobm+nt3TDQAUGpgEqKD6CPxNN
// SIG // ZgvAs0314Y9/HG8VfUWnduVAKmWjw11SYobDHWM2l4bf
// SIG // 2vP48hahmifhzaWX0O5dY0HjWwechz4GdwbRBrF1HxS+
// SIG // YWG18NzGGwS+30HHDiju3mUv7Jf2oVyW2ADWoUa9WfOX
// SIG // pQlLSBCZgB/QACnFsZulP0V3HjXG0qKin3p6IvpIlR+r
// SIG // +0cjgPWe+L9rt0uX4ut1eBrs6jeZeRhL/9azI2h15q/6
// SIG // /IvrC4DqaTuv/DDtBEyO3991bWORPdGdVk5Pv4BXIqF4
// SIG // ETIheu9BCrE/+6jMpF3BoYibV3FWTkhFwELJm3ZbCoBI
// SIG // a/15n8G9bW1qyVJzEw16UM0xghoKMIIaBgIBATCBlTB+
// SIG // MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
// SIG // bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
// SIG // cm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNy
// SIG // b3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExAhMzAAAE
// SIG // hV6Z7A5ZL83XAAAAAASFMA0GCWCGSAFlAwQCAQUAoIGu
// SIG // MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
// SIG // AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
// SIG // DQEJBDEiBCBNh76InfF4r0sZPyG1/HJTqPTzqVSyF85H
// SIG // F8/AtwayWDBCBgorBgEEAYI3AgEMMTQwMqAUgBIATQBp
// SIG // AGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5taWNy
// SIG // b3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBADtcz479
// SIG // z/tDu7WW4g6YBXDt5b9FEAehA9l0TRcWVcfuQRnaQjNv
// SIG // 8DBMwo3UU5m1MPkRPqxJUSrnH/vVPr5nYFa/iZ8rXC2o
// SIG // xdgZjv+djdX9o8y/H26oeQSoMW2hv6J3L9ufo4dftSYy
// SIG // b4htTIIx5oScn7BAsAlaDJPdB50Hky6fN7cphVLXP05w
// SIG // Q/lgWC86EftN4HBIU85jRC5iM+latxIfeGBSlUf2mmQg
// SIG // 0hs+glS/GktBMQ+rTotUNVaX7TNq/qSuxgxkdAEvsP4p
// SIG // ytLscCa1yNLTJKJdfsiidgk+NzQRpIzpnnTen7rvvl7r
// SIG // Yn/MQb8xS62R22wFWXb7hz/qs8OhgheUMIIXkAYKKwYB
// SIG // BAGCNwMDATGCF4Awghd8BgkqhkiG9w0BBwKgghdtMIIX
// SIG // aQIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUgYLKoZIhvcN
// SIG // AQkQAQSgggFBBIIBPTCCATkCAQEGCisGAQQBhFkKAwEw
// SIG // MTANBglghkgBZQMEAgEFAAQgzMSuR+unsYZSqA8qD3UB
// SIG // UK6ftNchnPI1V97niwHM6PACBmnBrx50VBgTMjAyNjA0
// SIG // MDEyMDM3NTEuNTM4WjAEgAIB9KCB0aSBzjCByzELMAkG
// SIG // A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
// SIG // BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
// SIG // dCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0
// SIG // IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNo
// SIG // aWVsZCBUU1MgRVNOOjkyMDAtMDVFMC1EOTQ3MSUwIwYD
// SIG // VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
// SIG // oIIR6jCCByAwggUIoAMCAQICEzMAAAIjT9lgJFPP/isA
// SIG // AQAAAiMwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMC
// SIG // VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
// SIG // B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
// SIG // b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
// SIG // U3RhbXAgUENBIDIwMTAwHhcNMjYwMjE5MTkzOTU3WhcN
// SIG // MjcwNTE3MTkzOTU3WjCByzELMAkGA1UEBhMCVVMxEzAR
// SIG // BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
// SIG // bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
// SIG // bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3Bl
// SIG // cmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
// SIG // OjkyMDAtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3Nv
// SIG // ZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG
// SIG // 9w0BAQEFAAOCAg8AMIICCgKCAgEAiukNp5OVlHSs0gkm
// SIG // n6flI1AEbFsRykut6yYRQv80mmxbpkwbmidEDa5qnr7m
// SIG // +Q2+30o+arcMCp4yDvdvh1xeu9fdn7oy+wxaLeVhI/wL
// SIG // RGf168xR4pipTdYeoBEMD+SOu8Is2j1uWc0gTaWiwYOa
// SIG // B7wEjzmbcHTVKGfg0Chd4SZdSmbqCJVSvqou3C44GpOr
// SIG // OaDmXEQjKyp7gt2qFWusEQ22LylLo+65BcfSjtD7Byf5
// SIG // Pi52TIIEYXoeAFXWsMofqDsyj45UBlDX0nllIMptlPQi
// SIG // 2vLbdJkF+A8Q8+vq2pudII9aAH8kOk0O6/ejwAxTigYG
// SIG // lO/nKR52mRvPXU3oEOsnQURiMnDsNXUV9nig0Uc84it3
// SIG // J9FmiJv+znhrMkCoyMxELlEw79CY//c0O7a7izjqSQ/f
// SIG // ASVTiu43vOEs9oW9x71Ek+49Y9jfKXg+qJZKRR0f9WfC
// SIG // c+BfppK1BezJjwIq2B0c7p2yINx6wzDcBWDe8gZAwOP1
// SIG // TKPQmNMvaBlKKtso2wsE4m8/VWJfd5wd0EIkwk/Z1tzP
// SIG // kzlgfjzK2aRMatQUh5ij8yKnoSqq1A6DN9zyvnRCsKWC
// SIG // xE+rl6uB7kETF1k//7D7m1J0AGmlDH0IQGUsttx7ccLT
// SIG // d3ivfk+MAmr9sEBbee3lDsFFufwwszBfbbmuR3tYTb4H
// SIG // AF2ohtcCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBTWwIfP
// SIG // b9vZz2PW8EG9UGAs8VYHlzAfBgNVHSMEGDAWgBSfpxVd
// SIG // AF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQ
// SIG // hk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
// SIG // L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
// SIG // JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwG
// SIG // CCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
// SIG // b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUt
// SIG // U3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMB
// SIG // Af8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4G
// SIG // A1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
// SIG // h0MHu8+baeDWcAH9XAfuHPSeLL8Nz+lqhgTMbas50ug3
// SIG // c1M0rVxwmj2YTONYNYihzZ5nJy48C7ozhGjY4Up1A4gG
// SIG // akI1uWWqTgcYHOxIIIYfZPq+/KlgHt6yeEKIQW4UhnWb
// SIG // Sor00Wnkapp4cvPk4ayocwnhMGmq1yYpmcEqXUEFA24X
// SIG // lh3sgMQEqrpbXeSjtJv1BbztN7X3qahlwOLQoP1hhAsC
// SIG // qjoyc6UQHzyAestR8la5Pr5i+a6RG08MCzrV+1sRRhvP
// SIG // nGC5PR42g5Ma2gPx2JSkEcdbHc2vsP4LpS8IDpwckSSh
// SIG // dq6/DOxTSJcKIussBaWjXPAOx3sGho4MP7X3BNutCNV3
// SIG // pBpbgDSPR5zjTmFpSOwSgUG1hNrXqOr7ENVYPAfK02Un
// SIG // j1XZly9Tz6qrNylXRSjOZGKHDwgzPulS99iFferBEn9k
// SIG // +w48Wp6QoNg9lGI+GdYu3MvFNSywxoOeSlrOGn9kUQYx
// SIG // 9jLpR4AJluaGysYmQg0I0Wq6CdlxJV1IYoBPQc74QhW0
// SIG // /xw2Nr6VaZeR50qXAksZi+YuZSE/8WwEDCOy7oe+V65v
// SIG // iLJXxVjhjhjJQqftuKhCRIJVxD+8cLKJTXQTZ3V4oYci
// SIG // Hn1RpSNQ0e8RhC4ia5PIn1VmKPVxGxF7/5W76ehdkdlL
// SIG // J8HlnJL6tMtR1pyxw6h+nT4wggdxMIIFWaADAgECAhMz
// SIG // AAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUA
// SIG // MIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
// SIG // Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
// SIG // TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylN
// SIG // aWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3Jp
// SIG // dHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAx
// SIG // ODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
// SIG // YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
// SIG // VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
// SIG // BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
// SIG // MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
// SIG // 5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1
// SIG // V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeF
// SIG // RiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDc
// SIG // wUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmvHaus
// SIG // 9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130
// SIG // /o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHI
// SIG // NSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56KTes
// SIG // y+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7vnGp
// SIG // F1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+
// SIG // /NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fz
// SIG // pk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNO
// SIG // wTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLi
// SIG // Mxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5
// SIG // UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9Q
// SIG // BXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6H
// SIG // XtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIG
// SIG // CSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYE
// SIG // FCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSf
// SIG // pxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEG
// SIG // DCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRw
// SIG // Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
// SIG // UmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUH
// SIG // AwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
// SIG // VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0j
// SIG // BBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0f
// SIG // BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0
// SIG // XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
// SIG // BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
// SIG // Ni0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1Vffwq
// SIG // reEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1
// SIG // OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulmZzpT
// SIG // Td2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinL
// SIG // btg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l
// SIG // 9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3+SmJ
// SIG // w7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2Fz
// SIG // Lixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7
// SIG // hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY
// SIG // 3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9swFX
// SIG // SVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFU
// SIG // a2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz
// SIG // /gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/
// SIG // AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1
// SIG // ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328
// SIG // y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEG
// SIG // ahC0HVUzWLOhcGbyoYIDTTCCAjUCAQEwgfmhgdGkgc4w
// SIG // gcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
// SIG // dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
// SIG // aWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1p
// SIG // Y3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNV
// SIG // BAsTHm5TaGllbGQgVFNTIEVTTjo5MjAwLTA1RTAtRDk0
// SIG // NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
// SIG // U2VydmljZaIjCgEBMAcGBSsOAwIaAxUAOEVhbPpE4mZ6
// SIG // GYgI9QbWI/MwjWqggYMwgYCkfjB8MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
// SIG // dGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsFAAIFAO13
// SIG // YO0wIhgPMjAyNjA0MDEwOTE2MjlaGA8yMDI2MDQwMjA5
// SIG // MTYyOVowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA7Xdg
// SIG // 7QIBADAHAgEAAgICzzAHAgEAAgISoTAKAgUA7XiybQIB
// SIG // ADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMC
// SIG // oAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3
// SIG // DQEBCwUAA4IBAQBew2JKOUt+WuoJdKNz7jGymlW/bXn5
// SIG // aKDj3GoOknahWaOlb86Sr6qbDRU/uQAzwdr4WY8pYEKC
// SIG // 7WzUEOmQAxe/rNfV7XsoUEU88STak3ftbmmUfANyg+oj
// SIG // APKMypKG0HD3xS9RhRwVrVC9GEBgXQZZpQFvJom8zMAA
// SIG // hItYQth+RCn5YzHbRThse4LK3Qou6+UluDljASCgSdmf
// SIG // b99eqR4lj+YOucndDCklUYwHwnvmONhf0jE6Hikh7mCj
// SIG // exkq74vBsTtWRreN3WejHl9pHnpJ6PeT6zzIrhrg91Nl
// SIG // E75bPgSbg9ND4uvstyr76YjonTSEHd1EX0PjA+TPguMf
// SIG // LCE3MYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMx
// SIG // EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
// SIG // ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
// SIG // dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
// SIG // bXAgUENBIDIwMTACEzMAAAIjT9lgJFPP/isAAQAAAiMw
// SIG // DQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzEN
// SIG // BgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgpRXK
// SIG // hZwMYyoF6rKsEsS+Fzi8lE/Gv/S0kY5uAWfEd6swgfoG
// SIG // CyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCCW8DMsEW73
// SIG // Bosp458IwKnGg+O8mL3mymUQL7RAEebuszCBmDCBgKR+
// SIG // MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
// SIG // dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
// SIG // aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
// SIG // Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAC
// SIG // I0/ZYCRTz/4rAAEAAAIjMCIEIFBRv4XojTygS10dMXB0
// SIG // ioJUDiJ5VisvsOkpzVA28wZiMA0GCSqGSIb3DQEBCwUA
// SIG // BIICABUXEXyIr3ZdHAnaOIZyQNvY/PtYpQF1jXz8eUKK
// SIG // jvB6GrBqfn3wfSxD40LB7FJ9P49pzuXGJ4SoYqaM60mN
// SIG // kDiJr2nP2G8k06w173p0hJ+HM5/hUY80v4vhGyB6SwW+
// SIG // 5NPEWiRkV31ycR/0T5NexMQ8uxKPyex/Lcfua4COcCHK
// SIG // OuclO+/RvVx2sfmY2w/ddbfFr19uRwnsvaulu9dJBEbC
// SIG // q9qEP7V+DhPUJqJcup+/nIKWYWQtXhuCq4a0dJIZafLi
// SIG // dTlr8BlvlbRYFFA563c46n9j62ikvhNU/TuOEXtXLplA
// SIG // EUHTmsLkh9tIhprt0zRL1mENIEt3gyd+0jb932gyyQGY
// SIG // Wn4lay1yx1d0KD2LvKwhgQg66x1kpxAKXWX623U8vIEn
// SIG // /gaz9feMRZbDmLMNkU5cJcHhFf0XBYCtdYPu/yKvKg/L
// SIG // 61G/2AZfvH9YNJaXUq8SITnflmnwByMK/VfUI1LQ/O9I
// SIG // MrxqW95/UwdK2ItLiSt3OoOqKOlotd7d2JTLHUreU4dD
// SIG // NB0YmQkyQGgcRgHhBDDreXUp1oW+BojozYNkukpPC6lI
// SIG // A2HXgryu8Bqnl1iGpAZ2hffxrwAmiDZf632UHh2vU2QX
// SIG // FI7JDe3ZLqxTQTExevB0my92f5FLTT3+YJe+R0RyME9/
// SIG // JvYJnzR4tcCpny2Jy51VmEce3oDY
// SIG // End signature block
