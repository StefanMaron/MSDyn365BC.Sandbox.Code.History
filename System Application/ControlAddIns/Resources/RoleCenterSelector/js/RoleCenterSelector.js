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
// SIG // MIInbgYJKoZIhvcNAQcCoIInXzCCJ1sCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // M2zDcK4qGbi+53CAFxQzQE5A3MM9E4R8cq4rHYYlsVGg
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
// SIG // 9hxwL30BElj9MYIZ/TCCGfkCAQEwbjBXMQswCQYDVQQG
// SIG // EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWdu
// SIG // aW5nIFBDQSAyMDI0AhMzAAACHPrNxZvoL37EAAAAAAIc
// SIG // MA0GCWCGSAFlAwQCAQUAoIGuMBkGCSqGSIb3DQEJAzEM
// SIG // BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
// SIG // BgEEAYI3AgEVMC8GCSqGSIb3DQEJBDEiBCD0QIPj+ETt
// SIG // 2X3cF9jh28gpVY/wHZcDrR/29wXMjgL3ljBCBgorBgEE
// SIG // AYI3AgEMMTQwMqAUgBIATQBpAGMAcgBvAHMAbwBmAHSh
// SIG // GoAYaHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqG
// SIG // SIb3DQEBAQUABIIBAI2LcEim3lr3VbzIOPTUGedcZRY6
// SIG // KnzVRPKy3dR1NDwSxT+FWQ2+bgMR81iFQlGJWVpTl4rr
// SIG // Mghb+il+SBAQSvIfGVQSyG5ZAB3Zk8P2dmAVafRSUk83
// SIG // ELb7POqBrc7DPBNuA2Fs0ryhpUBlUBT3HVKD33wACpLm
// SIG // 5Qh4PN7Oxx9iNcbiRsH8gulclFn+z36WvQ6ut6WCFlLr
// SIG // kU52l+2l2kYYm7jJ+8jtwdERrjGTDuEZpgi8ER8g06df
// SIG // GmQf/SxDdv02BBR3LTqkSjSt06YEA84+svUABIBVDNwW
// SIG // fsswTORpPdVCA0qbvJAWBGsJ3hN50J1fx3XQU5xkzYsQ
// SIG // Q8KPM22hghevMIIXqwYKKwYBBAGCNwMDATGCF5swgheX
// SIG // BgkqhkiG9w0BBwKggheIMIIXhAIBAzEPMA0GCWCGSAFl
// SIG // AwQCAQUAMIIBWgYLKoZIhvcNAQkQAQSgggFJBIIBRTCC
// SIG // AUECAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEF
// SIG // AAQg7pw19p1Nbm4qCPbiATpfMwFBUoeJfW8Rs+GAGemB
// SIG // 6bMCBmoRk4BpmBgTMjAyNjA2MDMxOTAyMTcuODYyWjAE
// SIG // gAIB9KCB2aSB1jCB0zELMAkGA1UEBhMCVVMxEzARBgNV
// SIG // BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
// SIG // HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEt
// SIG // MCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0
// SIG // aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRT
// SIG // UyBFU046NjUxQS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1p
// SIG // Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghH9MIIH
// SIG // KDCCBRCgAwIBAgITMwAAAhUYA9OBByZ8UwABAAACFTAN
// SIG // BgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
// SIG // A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
// SIG // ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
// SIG // Q0EgMjAxMDAeFw0yNTA4MTQxODQ4MjBaFw0yNjExMTMx
// SIG // ODQ4MjBaMIHTMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
// SIG // V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
// SIG // A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYD
// SIG // VQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25z
// SIG // IExpbWl0ZWQxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
// SIG // Tjo2NTFBLTA1RTAtRDk0NzElMCMGA1UEAxMcTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJKoZI
// SIG // hvcNAQEBBQADggIPADCCAgoCggIBAMNx1d4VcS9JRGD1
// SIG // dN13jSmede1SG4HsYZQz3aV8A0tAWLcT8IuF2KWUdZXd
// SIG // LunK9l47roHYOdA1MeVhy9EIWNnfb5CUpNNqxP++YXCr
// SIG // fdZtiIdvO0EcUTJhbtwReuOupPKqebl7X3urnIquPWGk
// SIG // vKfnc797k2qw+IUPFE+y2veaTiYkascXdKjhixArxyxF
// SIG // z14qDUsfacoc4Zupbe3sy8SXhVWLcUoZGrz6GTdHTgom
// SIG // HoeCoKCqMmoMzLkoiwojFFuFHuELJuufBSTRkzYe1eal
// SIG // 2FQOpOcY8OVnlnSjs9IvQOYwXG2PX1TqP3APItW8rc3A
// SIG // 08W953LXJcvPzmHjbLZGm/yLKtwsXtb6venyBxNfmRpi
// SIG // Y5GtbKHcKj8nFaf9rW/gY7pTy+Q+q4FF0zxfOFPNkSyh
// SIG // 1ee2wfHx0aYJ43FgULlz4FXkl6REVoprdDRdpQji86oK
// SIG // 70v72KnXuS5/WJSioQGf8QxNEyyCK+viP9iU7Vz9+J34
// SIG // 0xDVajASElnGpCMQMBm90QechwscpyBTVS3HygLBHQuV
// SIG // NnptHwL5lb9LKJ6p79e3LmmItngi1oaCtSHPOQ8O7P5Y
// SIG // XF6waWOJ/0ZeZd8B87OLziIbvOwyMuUFGhLqRLMmNDVq
// SIG // oCOAVper9cILHvpfA1hXlF6H4VLgoFU7kxzdyvInaDG5
// SIG // /EN3nVCBAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQUiSF3
// SIG // 8XKgMBaho/Y3cELXUqmnY9cwHwYDVR0jBBgwFoAUn6cV
// SIG // XQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKg
// SIG // UIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
// SIG // cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBD
// SIG // QSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBc
// SIG // BggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
// SIG // Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
// SIG // LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0T
// SIG // AQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
// SIG // BgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIB
// SIG // AHeNh7VfpBm78cywUwuTu75AiAT8vwcKYws3i+d4QIhD
// SIG // nm6flXTZ8JvRlQn2KtyjH64+FLykE1AGkuWZMHtYL2d5
// SIG // Y0kpwjskuTsDbvXaYN8MPkFtnjnEi5MlQFhay5+iIoN0
// SIG // wv81jL1Yal7XRYRtiidZUmzdttnLGNxN/waxpbgJbxE/
// SIG // YJsVcssTcuff+yRecyBnCYm8ncbPeCS9QbT4FyTn2c0P
// SIG // v94k3Ong7Zmlk+gynZyaHKfMJFyljyLARH5A+pNUIrcL
// SIG // 7dJh6zkWoe+Uo3nDireKFmslS5D04aNdntKJ4BINXI3u
// SIG // X8UmRrYazK1iryOEexxAu5PJmh/XjwN1Yh9AlUkjnn2j
// SIG // 0xjMyIRwqOad4xuUjHMjt3gPbhGmECSEyZSxtwcMBpsq
// SIG // WOwv/P549UjoYMdR4CdMsDiS/cXz+ADnFpgn27KoBmwm
// SIG // gu1h+bCDXc3zGq/Fe2DRapGwhlCoXPBqSMhPjCp8lZ99
// SIG // 47LmhgJTUYO3VUVEqGCycb1LMPRjsMgaQcGxPbKji5vh
// SIG // 7DtNKBdtzzIqO1hV3BU2QI6d7o4oQQHy61yAoBjhz3ZG
// SIG // dONrtS2ajnJ5a91874DHvpjz8mrFvH9K7cyY91eRPxCo
// SIG // skJT8Y/TH6tsfYYpp5V1hmQlT3hAUTqzWw2AX2s08izQ
// SIG // jk7EbZLDkldxQbT56ULSze+eMIIHcTCCBVmgAwIBAgIT
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
// SIG // BmoQtB1VM1izoXBm8qGCA1gwggJAAgEBMIIBAaGB2aSB
// SIG // 1jCB0zELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
// SIG // TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1p
// SIG // dGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046NjUx
// SIG // QS0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
// SIG // aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMV
// SIG // AI+nk3o27mBNSH42367erV3rwlEgoIGDMIGApH4wfDEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcN
// SIG // AQELBQACBQDtypFsMCIYDzIwMjYwNjAzMTE0MTMyWhgP
// SIG // MjAyNjA2MDQxMTQxMzJaMHYwPAYKKwYBBAGEWQoEATEu
// SIG // MCwwCgIFAO3KkWwCAQAwCQIBAAIBZgIB/zAHAgEAAgIS
// SIG // PTAKAgUA7cvi7AIBADA2BgorBgEEAYRZCgQCMSgwJjAM
// SIG // BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAID
// SIG // AYagMA0GCSqGSIb3DQEBCwUAA4IBAQCF6V15+0kKjGVC
// SIG // rfu8AAaTCXVxvLREj70tMWEkpGpy7jgqpGVio8Znmfyx
// SIG // KLeAB5sVEFRrgwf2ntuZ+8ibb3dID31GBtYeLXbEiKsW
// SIG // bph4TG5zwpHAwYu2QL83zqbXbOZovVlOXojcfzx3yu6H
// SIG // 3yAo0mfBT0mDaekXOFYvaoe4dKOFUl5Lq7vJ4H5PqXzp
// SIG // vq0hXUnOO1b285Hui11rBCLmnVcKFneNcw4GUludgPRH
// SIG // U2vMVk54VgA08gO8ZWY3znl2ido8RMbGeoD2atu4xC/W
// SIG // qt+9xB0Kkz6yTKnff654e9IP2ICAdejNUQUezxRNDEqq
// SIG // dGEzo0571vEcZ4IeOnzNMYIEDTCCBAkCAQEwgZMwfDEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
// SIG // b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAIVGAPT
// SIG // gQcmfFMAAQAAAhUwDQYJYIZIAWUDBAIBBQCgggFKMBoG
// SIG // CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG
// SIG // 9w0BCQQxIgQgZ570ZclRZoOjeOjVrIrFGa3QRJ0t77Fe
// SIG // MwJ0n9vP3/kwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
// SIG // MIG9BCBwEPR2PDrTFLcrtQsKrUi7oz5JNRCF/KRHMihS
// SIG // Ne7sijCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
// SIG // VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
// SIG // MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
// SIG // JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
// SIG // QSAyMDEwAhMzAAACFRgD04EHJnxTAAEAAAIVMCIEIMa4
// SIG // yAYz/DPM+/fo6pLWJZy5eoo4DiHD8FiMGkRKqQ2fMA0G
// SIG // CSqGSIb3DQEBCwUABIICAGbeoB0qP6zvUYoS3EWvx2ou
// SIG // ciAQZI7ZIWOW8xDMkQThic5ioWGyQO/qjNHhokb2Ys1l
// SIG // MaIWzg2WA6CNDS75me9G0xmitygVEzOjxIY+IFEsiWfh
// SIG // 55+xxq6k4MwcxuGctxJ83Ak5W2WmpZ3tDjEaWx2t9mJc
// SIG // BA8W+QPTCIDYx0ER6LFG/83++l93q8eSjn9IOSsFD4Kt
// SIG // abmsSA13oTfZVZbLB2+e1IUndOr8JI2AQgkhI7UY9diI
// SIG // qr9IdbuZsp2zd2+LxuWAw2kfl3fBKND01bvIj4xc0Pu2
// SIG // ydsTm73a6vFjJCJ7pYRGCKgOCb9YDEKtvlyLhWRt/2SO
// SIG // Ie8Wr9uajNR6PRvAsGNGaIgqps5ggX4cdMe78sZMgVs5
// SIG // d0T8eBDx7EByv3ea7NalB04d5Nw35hbv1Ct2r1+8UJL/
// SIG // AnUjZsZFTUJnyvguvaerNxu48t+tuoiGe5hECrhnOzAx
// SIG // BNhF02C6BT2ku/iBhWIlrDjXDukM3OlPy9sY8UCcgIBq
// SIG // e1VHhYqpN9dSpAaHmfGGgXNg61V5nKSdKsZWJgj+HkFb
// SIG // e3/0s8LTu/2VmU1XHXbD3U38y9FyfkrKwKgdKU+N0o22
// SIG // IgO7OmETqdgxhC8MsSKb63EozhTQMv+ey5Bsdzkm43y1
// SIG // EDgQ8d+8XzlUfNW8rNiGuyjHUq7v8UMXUFuxr8SLjt66
// SIG // End signature block
