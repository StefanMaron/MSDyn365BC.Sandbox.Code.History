var jsonContent;
var jsonPageData;
var actionLabel;
var pageDescription;
var disclaimerText;
var currentProfileId;
var currentSelectedIndex;

function LoadRoleCenterFromJson(jsonText){
    jsonContent = JSON.parse(jsonText);
    DrawFeatureContent();
}

function LoadPageDataFromJson(jsonText){
    jsonPageData = JSON.parse(jsonText);
    DrawPage();
} 

function GetCurrentProfileId(profileId){
    profileId = currentProfileId;
    return currentProfileId;
}

function SelectDropdownItem(index) {
    var dropdownItems = document.getElementById("select");
    for (var i = 0; i < dropdownItems.options.length; ++i) {
        if (dropdownItems.options[i].value == index.toString()) {
            dropdownItems.options[i].selected = true;
        }
    }
}

function SetCurrentProfileId(ProfileId) {
    currentProfileId = ProfileId;
    var index = jsonPageData.DropContent.map(function (d) { return d['Name']; }).indexOf(currentProfileId);
    currentSelectedIndex = index;

    SelectDropdownItem(currentSelectedIndex);
}

function DrawPage() {
    DrawCanvas();
    DrawDropdown();
    DrawFooter();
}

function ReplaceFeaturesContent() {
    $("#featuretable").remove();
    InsertFeaturesContent();
}

function InsertFeaturesContent() {
    var features = jsonContent;

    var tableDiv = document.createElement("div");
    tableDiv.className = "tableDiv";
    tableDiv.id = "featuretable";

    var table = document.createElement("table");
    table.className = "ms-Table ms-Table--fixed";
    tableDiv.appendChild(table);

    var thead = document.createElement("thead");
    table.appendChild(thead);
    var theadRow = document.createElement("tr");
    thead.appendChild(theadRow);

    for (var i = 0; i < features.length; i++) {
        var th = document.createElement("th");
        th.className = "tableheader ms-fontSize-mPlus ms-fontWeight-semibold";
        var callOutDiv = document.createElement("div");
        callOutDiv.textContent = features[i].name;
        th.appendChild(callOutDiv);
        theadRow.appendChild(th);
    }

    var expand = true;
    var index = 0;
    var tbody = document.createElement("tbody");
    table.appendChild(tbody);

    while (expand) {
        expand = false;
        var tRow = document.createElement("tr");
        tbody.appendChild(tRow);
        for (var j = 0; j < features.length; j++) {
            var td = document.createElement("td");
            if (index < features[j].rows.length) {
                expand = true;
                td.className = "type2 ms-fontSize-m ms-fontWeight-regular";
                callOutDiv = CreateCalloutElement(features[j].rows[index].name, features[j].rows[index].tooltip, j + 4, 'td' + index + j);
                td.appendChild(callOutDiv);
            }
            tRow.appendChild(td);
        }
        index++;
    }
        
    var pageHeader = document.getElementById("pageheader");
    pageHeader.parentNode.insertBefore(tableDiv, pageHeader.nextSibling);

    var Callouts = document.querySelectorAll(".msCalloutDiv");
    for (var k = 0; k < Callouts.length; k++) {
        var callout = Callouts[k];
        var CalloutTriggerElement = callout.querySelector(".calloutlabeldiv .calloutspandiv");
        var CalloutElement = callout.querySelector(".ms-Callout");
        new fabric['Callout'](
            CalloutElement,
            CalloutTriggerElement,
            "right"
        );
    }
}

function DrawFeatureContent() {
    if (document.getElementById("featuretable") != null) {
        ReplaceFeaturesContent();
    }
    else {
        InsertFeaturesContent();
    }
}

function DrawCanvas()
{
    document.getElementById("controlAddIn").innerHTML = "";

    var canvas = document.createElement('div');
    canvas.className = "mainCanvas";
    canvas.id = "mainCanvas";
    document.getElementById("controlAddIn").appendChild(canvas);
}

function OnChangeSelection()
{
    var selectedValue = document.getElementById("select").value;
    currentSelectedIndex = parseInt(selectedValue);
    currentProfileId = jsonPageData.DropContent[selectedValue].Name;
    SetCurrentProfileId(currentProfileId);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnProfileSelected', [currentProfileId]);
}
function DrawDropdown() {
    var canvas = document.getElementById("mainCanvas");

    var headerDiv = document.createElement("div");
    headerDiv.className = "header";
    headerDiv.id = "pageheader";
    canvas.appendChild(headerDiv);

    var titleLabel = document.createElement("label");
    titleLabel.className = "ms-Label";
    titleLabel.id = "dropdownLabel";
    titleLabel.textContent = jsonPageData.HeaderLabel;
    headerDiv.appendChild(titleLabel);

    var dropDownDiv = document.createElement("div");
    dropDownDiv.className = "ms-Dropdown";
    headerDiv.appendChild(dropDownDiv);
    var select = document.createElement("select");
    select.id = "select";
    select.tabIndex = 3;
    select.setAttribute("onChange", "OnChangeSelection()");
    select.setAttribute("aria-labelledby", "dropdownLabel");

    for (var i = 0; i < jsonPageData.DropContent.length; i++) {
        var option = document.createElement("option");
        option.value = i;
        option.text = jsonPageData.DropContent[i].Description;
        select.options.add(option);
    }
    dropDownDiv.appendChild(select);

    //var desc = document.createElement("label");
    //desc.className = "ms-Label";
    //desc.id = "actiondesc";
    //desc.textContent = jsonPageData.ActionDescription;
    //headerDiv.appendChild(desc);

    var button = document.createElement("button");
    button.className = "ms-Button";
    button.setAttribute("aria-labelledby", "actiondesc");
    button.tabIndex = 4;
    headerDiv.appendChild(button);

    var buttonSpan = document.createElement("span");
    buttonSpan.className = "ms-Button-label";
    buttonSpan.textContent = jsonPageData.DefaultActionLabel;
    button.appendChild(buttonSpan);

    button.addEventListener("click", function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnAcceptAction', null);
    });
}

function DrawFooter()
{
    var canvas = document.getElementById("mainCanvas");
    var footer = document.createElement("div");
    footer.className = "footer";
    footer.id = "footer";
    canvas.appendChild(footer);

    var messageBar = document.createElement("div");
    messageBar.className = "ms-MessageBar ms-MessageBar--warning";

    var messageBarContent = document.createElement("div");
    messageBarContent.className = "ms-MessageBar-content";

    var messageBarIconDiv = document.createElement("div");
    messageBarIconDiv.className = "ms-MessageBar-icon";

    var messageBarIcon = document.createElement("i");
    messageBarIcon.className = "ms-Icon ms-Icon--Important";

    messageBarIconDiv.appendChild(messageBarIcon);

    var messageBarText = document.createElement("div");
    messageBarText.className = "ms-MessageBar-text";
    messageBarText.textContent = jsonPageData.DisclaimerText;

    messageBarContent.appendChild(messageBarIconDiv);
    messageBarContent.appendChild(messageBarText);

    messageBar.appendChild(messageBarContent);

    footer.appendChild(messageBar);
}

/*
<div class="msCalloutDiv">
    <div class="ms-Callout is-hidden">
        <div class="ms-Callout-main">
            <div class="ms-Callout-header">
                <p class="ms-Callout-title">All of your favorite people</p>
            </div>
            <div class="ms-Callout-inner">
                <div class="ms-Callout-content">
                    <p class="ms-Callout-subText ms-Callout-subText--">tooltip.</p>
                </div>
            </div>
        </div>
    </div>
    <div class="calloutlabeldiv">
        <div class="calloutspandiv">
            <a>Open Callout</a>
        </div>
    </div>
</div>
*/
function CreateCalloutElement(featureName, featureDescription, tabIndex, cellId) {
    var callOutDiv = document.createElement("div");
    callOutDiv.className = "msCalloutDiv";

    var callOutWnd = document.createElement("div");
    callOutWnd.className = "ms-Callout is-hidden";

    var callOutMain = document.createElement("div");
    callOutMain.className = "ms-Callout-main";

    var callOutHdr = document.createElement("div");
    callOutHdr.className = "ms-Callout-header";

    var callOutTitle = document.createElement("p");
    callOutTitle.className = "ms-Callout-title";
    callOutTitle.innerText = featureName;
    
    var callOutInner = document.createElement("div");
    callOutInner.className = "ms-Callout-inner";

    var callOutcontent = document.createElement("div");
    callOutcontent.className = "ms-Callout-content";

    var callOutSubtext = document.createElement("p");
    callOutSubtext.className = "ms-Callout-subText";
    callOutSubtext.innerText = featureDescription;
    callOutSubtext.id = cellId;
    
    callOutHdr.appendChild(callOutTitle);
    callOutcontent.appendChild(callOutSubtext);
    callOutInner.appendChild(callOutcontent);
    callOutMain.appendChild(callOutHdr);
    callOutMain.appendChild(callOutInner);
    callOutWnd.appendChild(callOutMain);

    var callOutlabelDiv = document.createElement("div");
    callOutlabelDiv.className = "calloutlabeldiv";

    var callOutButton = document.createElement("div");
    callOutButton.className = "calloutspandiv";

    var callOutButtonSpan = document.createElement("a");
    callOutButtonSpan.innerText = featureName;
    callOutButtonSpan.setAttribute("aria-describedby", cellId);
    callOutButtonSpan.tabIndex = tabIndex;
    callOutButton.appendChild(callOutButtonSpan);
    callOutlabelDiv.appendChild(callOutButton);
    callOutDiv.appendChild(callOutWnd);
    callOutDiv.appendChild(callOutlabelDiv);

    return callOutDiv;
}

// SIG // Begin signature block
// SIG // MIIoJwYJKoZIhvcNAQcCoIIoGDCCKBQCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // M2zDcK4qGbi+53CAFxQzQE5A3MM9E4R8cq4rHYYlsVGg
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
// SIG // a/15n8G9bW1qyVJzEw16UM0xghoJMIIaBQIBATCBlTB+
// SIG // MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
// SIG // bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
// SIG // cm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNy
// SIG // b3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExAhMzAAAE
// SIG // hV6Z7A5ZL83XAAAAAASFMA0GCWCGSAFlAwQCAQUAoIGu
// SIG // MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
// SIG // AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
// SIG // DQEJBDEiBCD0QIPj+ETt2X3cF9jh28gpVY/wHZcDrR/2
// SIG // 9wXMjgL3ljBCBgorBgEEAYI3AgEMMTQwMqAUgBIATQBp
// SIG // AGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5taWNy
// SIG // b3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBADnBZzJC
// SIG // 9NNtcJCOOBVz1TebUmpupb/MNp70x29wzrc0oFDraWyI
// SIG // G9W75zmB9B3Si3RnEvlFz3e+oPKorsO3/3SRvk6Pu0PT
// SIG // cnDq/vWgT+N8n8+2uOwcRxqYywCHGJ0D6KPrKHim0d6p
// SIG // fpHNLOS2zxsPIQTfHh5k1nffkyg8ZzsyKm6yghxy4vUM
// SIG // BPqhAXZTW0oAnA36ljiLgQt784vMxO/kbogVCOqLFcp/
// SIG // E6nwlyp21zG79PmW/GKR2Osl/229FiaJoxNIbEDvZ6JF
// SIG // BDhTL75LZrurbtZXZtVzAQOCG6cpXSVjrPd/ykhP7Tsr
// SIG // xBIQRwrsg8DVhsrnB78PmVz8gy+hgheTMIIXjwYKKwYB
// SIG // BAGCNwMDATGCF38wghd7BgkqhkiG9w0BBwKgghdsMIIX
// SIG // aAIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUQYLKoZIhvcN
// SIG // AQkQAQSgggFABIIBPDCCATgCAQEGCisGAQQBhFkKAwEw
// SIG // MTANBglghkgBZQMEAgEFAAQgkWeVv2e3Wc7RtPV9R+NQ
// SIG // sYIUhSGDLfbcF+n5bvjja68CBmnBSK43QxgSMjAyNjA0
// SIG // MDEyMDM3NTEuNzFaMASAAgH0oIHRpIHOMIHLMQswCQYD
// SIG // VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
// SIG // A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
// SIG // IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQg
// SIG // QW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hp
// SIG // ZWxkIFRTUyBFU046QTAwMC0wNUUwLUQ5NDcxJTAjBgNV
// SIG // BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
// SIG // ghHqMIIHIDCCBQigAwIBAgITMwAAAiu7AFD/TTuaoQAB
// SIG // AAACKzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJV
// SIG // UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
// SIG // UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
// SIG // cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
// SIG // dGFtcCBQQ0EgMjAxMDAeFw0yNjAyMTkxOTQwMTFaFw0y
// SIG // NzA1MTcxOTQwMTFaMIHLMQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVy
// SIG // YXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046
// SIG // QTAwMC0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29m
// SIG // dCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3
// SIG // DQEBAQUAA4ICDwAwggIKAoICAQCX3mi6OD3syUqQm4Qq
// SIG // gkrKPbcsK/Qx3fYctL8+VM1uOY3booi5GxwauTgQf6JF
// SIG // HITToxS7gjqKlK8OFLzL6UTl0jxEK5t6DuOcgJXdvuti
// SIG // moTlOS0C3kyITXBAXoj/gp6hRR9z6WRip1Ktkilb3dJX
// SIG // CjQqT9P2Cuujr+Vz8r+Z+jDl09ji/ic/4G34r3mVwjs/
// SIG // /Gnx9Pu31V8rXFicNiAzxpubawpbd8pqfzlWT2vnG3kF
// SIG // 9l6MiREbvJ3XHLUwHQsh0t/TrSFx/s/yCqpJWYJ6oClG
// SIG // 70tvsFH0aRP8wB4cP/CFa2ILvk26i3OcJBl+pqKjHTSB
// SIG // y9mvwTPEDlnzco0Nt8R6pSPTXZgBsscHhoKfC0WQmOzY
// SIG // 2keXbAmRTcZMyXz5v/AJbmoI0y07Bazvt5NkXddG9TEr
// SIG // QWwtsFyIKrElDgWfHeCoTu1wu2ciD3dK72z3ca2gzoED
// SIG // xT2j9BXIUKaiTzTdQPRsAMaO3dU0zaGwMMlwtSJyDh14
// SIG // YEgZoUu5vS8MugMqdrNjphyL65yKhjpAWbhYkIHO/0uZ
// SIG // ju95tP8zZNqXIRh4tdfWHJPATn9r+cxkyuh2x0VLdfx1
// SIG // lmK9X3NjH0NtgAs5JB/wOlkyuudxmFTfWVyRrL37ispO
// SIG // Z8aPAFgvyR6cNTkGpkFo35JRjciNmZiU4qT9Uty+V5gu
// SIG // dFk1jwIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFD4WjuQT
// SIG // UJbtbd3jmvZku0FZ2eU2MB8GA1UdIwQYMBaAFJ+nFV0A
// SIG // XmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
// SIG // Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
// SIG // Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0El
// SIG // MjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYI
// SIG // KwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
// SIG // bS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1T
// SIG // dGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB
// SIG // /wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYD
// SIG // VR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQDO
// SIG // /CKsciEM8kr1fqH4TlfT66ENoTjxXw810pyEq0PdrgLw
// SIG // fgT3x+1gz7CQHtUdevqMQ5qHyDLhm6pT911CYkGN+6g+
// SIG // MU7fMYTr6d3SxieJwBIoWkfR4g7SitGzMKU465KEYejf
// SIG // ddoUgovC/xcRpaALO5p3/A248ByhJiMttBQNDtsT/HaC
// SIG // FwRFCURby/f8c1kky8F8xkCXFz+/MtZ5d1lWFjwOI2ge
// SIG // ZHWq9XihDOgee5nS2koo5V6n8XG220UTevVf+pgmpIH7
// SIG // 1XKDVIYTGGZJs6yPlfJ2aXqw1ME4NR6okNsY3P1M31H6
// SIG // DMYRfJGNBNep595kXGh3YzA3cCiyg+jmJ58h/fTvjngI
// SIG // puUFfODpDjFx0ic1YoLANxhCF3RhS9qYM7K40NEhKshY
// SIG // uaAkIG2XBKYig3r/0/b0sjvjBws55AYonMm3A8qcX/6k
// SIG // 9Vfc0mv9dtonHuWGfA2b+qE2qpCnhzGbdDHq7iOSZEw0
// SIG // 1nNupAMf1c41k9IoTQ2z3iw6w4ZZoLOyg4TKMbp1krpT
// SIG // 4trip/y30Cv5khyqCDNqaXQpBkOYON8LgtoQ3amVOX7i
// SIG // x5jdrnx/vUxTUSigXvrWdL7Uk8kpmS0zto2Toy7aT5oB
// SIG // zCTvfj9iJ/BN/E1vhFBkhJCvZ7PVvsMSnTTmkx2Fal2l
// SIG // VkztuAI44fD/uyLJdaMQSzCCB3EwggVZoAMCAQICEzMA
// SIG // AAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAw
// SIG // gYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
// SIG // dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
// SIG // aWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1p
// SIG // Y3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
// SIG // eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4
// SIG // MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
// SIG // c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
// SIG // BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
// SIG // AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
// SIG // ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk
// SIG // 4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX
// SIG // 9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VG
// SIG // Iwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzB
// SIG // RMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2
// SIG // Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+
// SIG // jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1
// SIG // KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL
// SIG // 64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakX
// SIG // W2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX78
// SIG // 2Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOm
// SIG // TTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07B
// SIG // MzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIz
// SIG // GHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
// SIG // +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
// SIG // emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode
// SIG // 2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJ
// SIG // KwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQU
// SIG // KqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+n
// SIG // FV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYM
// SIG // KwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6
// SIG // Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9S
// SIG // ZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcD
// SIG // CDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNV
// SIG // HQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
// SIG // GDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8E
// SIG // TzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5j
// SIG // b20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRf
// SIG // MjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoG
// SIG // CCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
// SIG // b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
// SIG // LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt
// SIG // 4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U5
// SIG // 18JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN
// SIG // 3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu
// SIG // 2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2
// SIG // pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnD
// SIG // vBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMu
// SIG // LGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG
// SIG // +jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+Cljd
// SIG // QDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJ
// SIG // VGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRr
// SIG // akURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+
// SIG // CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8C
// SIG // wYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVn
// SIG // K+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
// SIG // 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
// SIG // ELQdVTNYs6FwZvKhggNNMIICNQIBATCB+aGB0aSBzjCB
// SIG // yzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
// SIG // b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
// SIG // Y3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWlj
// SIG // cm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UE
// SIG // CxMeblNoaWVsZCBUU1MgRVNOOkEwMDAtMDVFMC1EOTQ3
// SIG // MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
// SIG // ZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQAJrD90ykHpo/0A
// SIG // Gb7lmwvsCtqROaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVT
// SIG // MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
// SIG // ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
// SIG // YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
// SIG // YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA7Xej
// SIG // MzAiGA8yMDI2MDQwMTEzNTkxNVoYDzIwMjYwNDAyMTM1
// SIG // OTE1WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDtd6Mz
// SIG // AgEAMAcCAQACAh9yMAcCAQACAhOgMAoCBQDtePSzAgEA
// SIG // MDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKg
// SIG // CjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcN
// SIG // AQELBQADggEBABvcCr8aMDJgmCeGnm/WdW3SYFBua/bk
// SIG // L/HPoJcDgxgb1HwrSjz8goXxZUl/d1fRlfm8hsZelcAP
// SIG // 9HLLrt0BHyqR3IsJYRSd7T+7NT/JFwUZP+uWT4n6pHMZ
// SIG // lNOCW4yRCDDEMQYnMPqAeizfz4ElaDPN9793FwygfiPe
// SIG // 2KVSf27TC6pARDPTyKthkTca+eNV+jw7CeiH5IUpA91K
// SIG // uxAhw3kNKV7fUc1R10v+ME1KTaI4Up0eBnPEGdnMwfyI
// SIG // rXumWHyBymd/GkxD0AP/pXhucAlSiZ/YVWhAwrF9V/hq
// SIG // tBOBtqv2Vxqh/vygaNB/ObU6/3UhDpcW7j6BlCmhJLY7
// SIG // 4WwxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzET
// SIG // MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
// SIG // bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
// SIG // cCBQQ0EgMjAxMAITMwAAAiu7AFD/TTuaoQABAAACKzAN
// SIG // BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0G
// SIG // CyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCCCc+FA
// SIG // KbJcwR9S2JBABTsJULCNU+GKrj7JYy8RCOvxqzCB+gYL
// SIG // KoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIHIOI/Q/kFft
// SIG // YA+M2OY+1Bx3ajBD6/WDAtPT2vFkv25SMIGYMIGApH4w
// SIG // fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
// SIG // b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
// SIG // Y3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
// SIG // cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAIr
// SIG // uwBQ/007mqEAAQAAAiswIgQgyVSRW7sTsD24/2cVzBK9
// SIG // eld/+Jb3qJP1oc3yAe7GXhkwDQYJKoZIhvcNAQELBQAE
// SIG // ggIADQCskq95wNSy6hvnN2/JKepSahNN68EzhEBlvmIJ
// SIG // ewd1COP0eBsYGqi/kW5145m+UfqzmMgrgWLsZdzdeo0/
// SIG // t5j4NP7xbT5Cnv8W+A0sGIrfPjUkNkUMrIzyYJ7SOqbW
// SIG // uNjCAR/c7LGxON8gfsCVitx4M9MKMkackzVQ8H2OLXxg
// SIG // YsZFM7d0hO4D4EMgiiKnC2572voRldgdlKARI0r6weCN
// SIG // R6CFAA7I6/q5I8OPsRDk43oujCDsbbsP2AyBi4OZtNfT
// SIG // n2HiSrwl/2VdTGAZRHglXoq6OeBelYl59F5hPkUPN+M1
// SIG // K2PcyRktq0pDw6sz6zzjEWSFa0eI3KBUZZ0Bsc54X7MJ
// SIG // uiCUiOGpRs5xgiJ9hPpO5TMhGx7cHm81t97ebXJHvqt+
// SIG // xl9v2q+mt8uK8wjkbZ9MPFblnmTP1OsD3+1i4WHjHb0u
// SIG // pTAfmbFI/tX8M4GcpQ+HE9DUABbeORQH5KJOAnVN3CIK
// SIG // m9ZcVYzFVX+riLJOkowuReM2ytYB7oYOXx+Rzpt/QARW
// SIG // AH03As16gCURCFjaKbAVe+4dx1zwo6fq5UpHmw4sTj9z
// SIG // B+7zmEI9IfnDPxVC5bXNYiBrTZe1oKlfQRxzoo9WcrUI
// SIG // 3xOoj28LiXQsidpXX3VHBwzaAuihZKf/pUHZ690h1bY4
// SIG // QiEq/CReAIBhaO3Zon/Y3vYGOEw=
// SIG // End signature block
