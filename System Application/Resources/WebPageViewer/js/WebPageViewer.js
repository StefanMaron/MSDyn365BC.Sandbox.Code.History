/*! Copyright (C) Microsoft Corporation. All rights reserved. */

var iframe = null;
var subscribeToSrcLoad = function () { };
var maxSize = 300;
var defaultSize = '100%';
var iframeHeight = defaultSize, iframeWidth = defaultSize;
var pageTabSize = 20;

function InitializeIFrame(ratio) {
  SetIFrameSize(ratio);
}

function InitializeFullIFrame() {
  SetFullIFrameSize();
}

function SetIFrameSize(ratio) {
  var controlAddInElement = document.getElementById('controlAddIn');
  var controlAddInWidth = controlAddInElement.offsetWidth;
  var controlAddInHeight = controlAddInElement.offsetHeight;
  var arr = ratio.split(":");
  var ratioWidth = arr[0];
  var ratioHeight = arr[1];

  var heightMaxRatio = Math.ceil((controlAddInHeight - pageTabSize) / ratioHeight);

  do {
    iframeWidth = Math.ceil(heightMaxRatio * ratioWidth);
    heightMaxRatio--;
  } while (iframeWidth > controlAddInWidth);

  iframeHeight = ((heightMaxRatio + 1) * ratioHeight) + pageTabSize;

  iframeWidth = iframeWidth < maxSize ? defaultSize : iframeWidth;
  iframeHeight = iframeHeight < maxSize ? defaultSize : iframeHeight;
}

function SetFullIFrameSize() {
  var controlAddInElement = document.getElementById('controlAddIn');
  var controlAddInWidth = controlAddInElement.offsetWidth;
  var controlAddInHeight = controlAddInElement.offsetHeight;
}

function SetContent(html, javascript) {
  iframe = WebPageViewerHelper.CreateIFrame(iframeHeight, iframeWidth);

  WebPageViewerHelper.SetBodyContent(iframe);

  WebPageViewerHelper.IFrameReady(iframe, function (event) {
    iframe.contentDocument.body.innerHTML = html;

    if (typeof (javascript) !== 'undefined') {
      WebPageViewerHelper.RunJavascript(javascript, iframe.contentDocument);
    }

    WebPageViewerHelper.UpdateLinks();
    WebPageViewerHelper.ChildDocumentReady();
    WebPageViewerHelper.HideSpinner();

    event.preventLoadEvent();
  });
}

function Navigate(url, method, data) {
  iframe = WebPageViewerHelper.CreateIFrame(iframeHeight, iframeWidth);

  try {
    if (typeof (method) === 'undefined' || typeof (data) === 'undefined') {
      if (url.substring(0, 8).toLowerCase() !== "https://") {
        throw 'Insecure URL Specified';
      }

      WebPageViewerHelper.SetBodyContent(iframe);

      subscribeToSrcLoad = WebPageViewerHelper.BindSrcLoadEvent(iframe);

      WebPageViewerHelper.IFrameReady(iframe, function () {
        iframe.setAttribute('src', url);
        WebPageViewerHelper.ChildDocumentReady();
      });

      return;
    }

    data = JSON.parse(data);
    var form = WebPageViewerHelper.CreateFormWithData(method, url, data);

    WebPageViewerHelper.SetBodyContent(iframe);

    WebPageViewerHelper.IFrameReady(iframe, function () {
      iframe.contentDocument.body.appendChild(form);
      form.submit();
      WebPageViewerHelper.ChildDocumentReady();
    });
  }
  catch (ex) {
    WebPageViewerHelper.HandleException(ex);
    WebPageViewerHelper.HideSpinner();
  }
}

function LinksOpenInNewWindow() {
  WebPageViewerHelper.Properties.LinksOpenInNewWindow = true;
  WebPageViewerHelper.UpdateLinks();
}

function InvokeEvent(data) {
  // Receive events with window.addEventListener('webpageviewerevent', function (e) { });
  WebPageViewerHelper.TriggerEvent(data);
}

function SetCallbacksFromSubscribedEventToIgnore(eventName, callbackResults) {
  if (typeof eventName !== 'string' || !eventName) return;

  if (!callbackResults) {
    callbackResults = [];
  }

  WebPageViewerHelper.SetCallbacksFromSubscribedEventToIgnore(eventName, callbackResults);
}

function SubscribeToEvent(eventName, origin) {
  var originFilter = "*";
  if (origin !== 'undefined') {
    if (origin.substring(0, 8).toLowerCase() !== "https://") {
      throw 'Insecure URL Specified';
    }

    originFilter = origin.substring(0, origin.indexOf("/", 8));
  }

  var recieveMessage = function (e) {
    if (e.origin !== originFilter) {
      return;
    }

    var s = JSON.stringify(e.data);
    var callbackResults = WebPageViewerHelper.Properties.IgnoreCallbacks[eventName];
    if (callbackResults) {
      for (var i = 0; i < callbackResults.length; i++) {
        if (callbackResults[i] === s) return;
      }
    }

    WebPageViewerHelper.TriggerCallback(s);
  }

  WebPageViewerHelper.SubscribeToEvent(eventName, recieveMessage);
}

/// <summary>
/// Posts a message (aka event) to the current iframe content window for the target domain.
/// </summary>
/// <param name="message">The JSON string that represents the message to be posted.</param>
/// <param name="targetDomain">
/// The domain to post the message to. This must match the domain of the iframe or the message will not be received. 
/// Do not use the wildcard domain (*) as this is deemed unsecure, possibly allowing messages to be intercepted.
/// </param>
/// <param name="convertToJson">Flag indicating whether we want to convert message to Json object or not.</param>
function PostMessage(message, targetDomain, convertToJson) {

  if (typeof message !== 'string' || !message) return;
  if (typeof targetDomain !== 'string' || !targetDomain) return;

  if (convertToJson) {
    message = JSON.parse(message);
  }

  if (subscribeToSrcLoad) {
    subscribeToSrcLoad(function () {
      iframe.contentWindow.postMessage(message, targetDomain);
    });
  }
}
// SIG // Begin signature block
// SIG // MIInRgYJKoZIhvcNAQcCoIInNzCCJzMCAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // K/T7jnK2YQnYVTbIYH8LmjtMVoXn+uPVg+wzpzjyNTGg
// SIG // ggy6MIIF9TCCA92gAwIBAgITMwAAAh1NGchO1w9XSAAA
// SIG // AAACHTANBgkqhkiG9w0BAQsFADBXMQswCQYDVQQGEwJV
// SIG // UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
// SIG // MSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5n
// SIG // IFBDQSAyMDI0MB4XDTI2MDQxNjE4NTk0M1oXDTI3MDQx
// SIG // NTE4NTk0M1owdDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
// SIG // Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
// SIG // BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEeMBwG
// SIG // A1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjAN
// SIG // BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0L3sF8cf
// SIG // YGWRQumLNVgWsvASfJBgOCUJx+QjGn6jgEpU6SvR/KOW
// SIG // V017dHGlUEzTFD7eOOcF2A/nRbWilk8A59SOdqFEqwvb
// SIG // yYp9RrKrfs8iiS+Q4N3kF20DUetQ5jMttBi0yDt0hXnf
// SIG // UX4v6KYYAixhSw0d69Crx48DG/42FktHHpVf+C89uy3w
// SIG // HpJvL/ROSF2nol2wFGGSitPdJ+AlZdyQbWzfvQ7SPUjb
// SIG // v8o76M1udv7u0V/07aWvyg5abqJGfmXG75rXfbq/YBS7
// SIG // 2c4eNaPTLBP3JULXWhVhr7qOibmv57aYJHstxOf7wRXv
// SIG // jCTxuqYXZ7qOq+e2bnQrnYiNWwIDAQABo4IBmzCCAZcw
// SIG // DgYDVR0PAQH/BAQDAgeAMB8GA1UdJQQYMBYGCisGAQQB
// SIG // gjdMCAEGCCsGAQUFBwMDMB0GA1UdDgQWBBR+kLjMKnDx
// SIG // tIUJUOnOYwrU0y61XjBFBgNVHREEPjA8pDowODEeMBwG
// SIG // A1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMRYwFAYD
// SIG // VQQFEw0yMzAwMTIrNTA3NTU5MB8GA1UdIwQYMBaAFH9Z
// SIG // P1Qh2q1P7wXl5qPXLQaUEggxMGAGA1UdHwRZMFcwVaBT
// SIG // oFGGT2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
// SIG // cHMvY3JsL01pY3Jvc29mdCUyMENvZGUlMjBTaWduaW5n
// SIG // JTIwUENBJTIwMjAyNC5jcmwwbQYIKwYBBQUHAQEEYTBf
// SIG // MF0GCCsGAQUFBzAChlFodHRwOi8vd3d3Lm1pY3Jvc29m
// SIG // dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMENv
// SIG // ZGUlMjBTaWduaW5nJTIwUENBJTIwMjAyNC5jcnQwDAYD
// SIG // VR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEASk22
// SIG // Do88Exvw1xms/bOvn0Hmk7Q3BZjGPuVMlRQso+z7/uYt
// SIG // +6n1/JUi/7QSH2EH1rDLgUJX2bqyQ+q+B1Sdgnh/tX4I
// SIG // qvHXB3VSqGd0mtql6F93KvYkvHFW9Oge/uf1yeyNDsRx
// SIG // /Xw7Lyd098OVf2bQCBZi65fj9ArRvvdrs0bJ9J023RYz
// SIG // pCzC1jywFN0x6ISkZUhDIBSaT5JuZ+VAGd+cV+hVgqwy
// SIG // 7Eim+eeW04n8GvJiQcHZaH9G5n2InR/ncWdRXQ8by5zZ
// SIG // fc3irAOJHo2miKqiD4LocALYuUJewZUzaCTcMQrwZqlt
// SIG // jEC5wpGDf1VVLEd1dsf63Ezc6AX/2f0qUTr3WgNmTjnd
// SIG // boqFybd7XS0O7x6aqYm9Cn1q/xVl1tdKt/FcXwp0UAas
// SIG // 20rs7Ue5xDLs1+wpPgf12jw13daoe9vkGMgdGdlc1pjv
// SIG // c7J2/VKv3cLvCxnkKp8ruu0gxgAr514otn2/flEuPdlU
// SIG // 510pxSsqsIM1MhTLWStf7B2E7+mxuE7UFMoEMUzfmVfm
// SIG // iSJSjtjKme2yqwJzs0vZujYKE3VjqtdW0zmcCpSBFfxI
// SIG // VfUlpA5naUf4Tz09r+kxI+BfD0/8x40XsyFOXPwxpbf1
// SIG // YWP6StF5CbRMjJpktQTLY1P66gWVTCJt3Z8ULP0wQcq/
// SIG // gn/Gda+2on0FUPlkqs4wgga9MIIEpaADAgECAhMzAAAA
// SIG // OTu2Nxm/Bh1nAAAAAAA5MA0GCSqGSIb3DQEBDAUAMIGI
// SIG // MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
// SIG // bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
// SIG // cm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNy
// SIG // b3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkg
// SIG // MjAxMTAeFw0yNDA4MDgyMDU0MThaFw0zNjAzMjIyMjEz
// SIG // MDRaMFcxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
// SIG // b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jv
// SIG // c29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMjQwggIiMA0G
// SIG // CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDYAZwe4zjH
// SIG // qpUWBzWtuub+CGPXx/EyoXph3zyDXtYKS2ld3YYN9uFs
// SIG // B9Oi3B26Z7AbpAgzYra8qNHbUvxFuiP8hC/2y0mPISqW
// SIG // 30LlrrAT6/ams2HA8Qlv6p42+SbCNbPGzToN21QE70FS
// SIG // +LXH9N2k8nLM/EHgnTNJf8h0TmyfUKmszNa+lTxDieyy
// SIG // /rhBG+98OkArobPPWtbr9c3qzmDJ7J3kUcAm6cltdSHI
// SIG // IFNHESgw6taY1ScyGyBevqIl120XjrIHiPM7tRckHytH
// SIG // 1ZGsmvEplR0P7Tn9t5meFvZNEYttkFvad1IEguTlA5LS
// SIG // scXAphi+rVy3zhklhyCFeGK0yU0+jzbcuURKIxybmRwK
// SIG // 5BfVZx0xEVqE4wM3yN5D/uW+GpVHYYAGe7bTrtW1Z13x
// SIG // 2qj2Jdqz7NtI4tNyzlVrIf62nYBNe3rOYS/repVdHlR6
// SIG // 1YbLLETlibs9jFzAre4sO5RTxvS1yho7JqJ59oKLRnRy
// SIG // LhIOSZyTCVZosXeS0ZZJoGEWSs4cUgsMqBiKtD4WgO2P
// SIG // lT3LeaQh5Io3CCA5tJ5ZCvtCsnqaJXKhptE/xmEETIRy
// SIG // ZRjjplUKKd+sFFVGJJVMvvrw1nhIBKOLO4cTepiG39jE
// SIG // iEP4iHzGYCcQuvaLpDFFwqzgt0pBP8SJIKX5dtjDNYrZ
// SIG // Gd+ZzV5DKJVNZQIDAQABo4IBTjCCAUowDgYDVR0PAQH/
// SIG // BAQDAgGGMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQW
// SIG // BBR/WT9UIdqtT+8F5eaj1y0GlBIIMTAZBgkrBgEEAYI3
// SIG // FAIEDB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/
// SIG // MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO4eqnxzHRI4k0
// SIG // MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWlj
// SIG // cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jv
// SIG // b0NlckF1dDIwMTFfMjAxMV8wM18yMi5jcmwwXgYIKwYB
// SIG // BQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3
// SIG // Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0Nl
// SIG // ckF1dDIwMTFfMjAxMV8wM18yMi5jcnQwDQYJKoZIhvcN
// SIG // AQEMBQADggIBABSUHzgoT+6J5+nyyDCq0pTdVmCsAxYA
// SIG // HXcpjlDtxazPHewf1v4kOg8V7A5+w+VuMDMGHi8rLXBK
// SIG // n5I8+DVEUYGs8jLuckc0IeC6owOLUrU3CYdaKRMaO55+
// SIG // T7jwWJ27tPkx0rlR03tFU0z1YYpcv6Yhaw6N2sUPT+Av
// SIG // jpecnrftoE33pCAkucUvnGH0iL4J9CZLFQVTGFSOUBbv
// SIG // 6oZy4bBBRFMxvH779IY4JDvpZKVfbcuhpDeL3Z3e8muk
// SIG // Omkfct+GojNapsWsQYujlJ8jZen5Lrp/3YkxZ2Ay06aT
// SIG // pK/5oOVknwog1TDQsbY+MDyguTph5tQ0CLfzDaJG2x91
// SIG // BrBT9UG87C6HLkqiwrx9PSKN3wz05rHEfWO+RuKl+0U1
// SIG // /AHQT6NCOjhKI39/c7hWbdKjh5uuWFkBOvXGTNrnhNTA
// SIG // dOXTTYByvYExO8yryv34PAdqo1vPDE/1heVebr2Rramv
// SIG // RUi9kWswKwPqwz7n+iRmM+B6YDGRweEurM1kimAb9FYr
// SIG // As38YHlPnarl1vW3dGrmJTgefAz3DmCnXN0nveIPsS+K
// SIG // XBIWweeCToAJMGE7v/XS3h9qQ6niWQAAVQ1kUAml3zuS
// SIG // 4MisCgi2F6YoK2WAo1EgXK/lXvDxVjIVU0JdL+KvCfwF
// SIG // JkDeVuJ9dNXGNi+AOxk0BtYd9hxwL30BElj9MYIZ5DCC
// SIG // GeACAQEwbjBXMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
// SIG // TWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9N
// SIG // aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDI0AhMz
// SIG // AAACHU0ZyE7XD1dIAAAAAAIdMA0GCWCGSAFlAwQCAQUA
// SIG // oIGuMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
// SIG // CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
// SIG // SIb3DQEJBDEiBCD/3xo7gvYWAadmSaU5mPhed3oAiewn
// SIG // fiF5hRcd/g61jTBCBgorBgEEAYI3AgEMMTQwMqAUgBIA
// SIG // TQBpAGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5t
// SIG // aWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAEcw
// SIG // MlO0AkmoW6I3LV3LklpVdNzVZ/wHuePMLQhdAoEpSXjz
// SIG // QIj5IQlJjHVC3+Oid3SjrJ8O03V9pOMbng5Dvp01ya8+
// SIG // gRJkf4m6kXRnWyGTpcamaczq7NIm835AsIUWfAZCl9N+
// SIG // Qs3QRMLh7OrXYt8QAehvq76oR5qkdCesSSrK5cQV1rTG
// SIG // bHnJZtkz55sAQx8MObsXgEyhJ/kZaEqkFibuvP2/QMC9
// SIG // oSCZEAFIxfjerzQMA9u2cizrgwMUPF8xcmgCbRVhPZ5S
// SIG // n+yAxhtyE4oXCGEQcM+G8+zhYHkAOJrH56y4gSAZBJGg
// SIG // 7N/6vvXlMLoU894IyLtSBadku/bYh2ahgheWMIIXkgYK
// SIG // KwYBBAGCNwMDATGCF4Iwghd+BgkqhkiG9w0BBwKgghdv
// SIG // MIIXawIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUQYLKoZI
// SIG // hvcNAQkQAQSgggFABIIBPDCCATgCAQEGCisGAQQBhFkK
// SIG // AwEwMTANBglghkgBZQMEAgEFAAQgO5QFa1RJh0EbgqS4
// SIG // 9rVXIjj+eotGJYrakCxv/1JE3yICBmrZS7pcdRgSMjAy
// SIG // NjExMDQwODIxMjguMTFaMASAAgH0oIHRpIHOMIHLMQsw
// SIG // CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
// SIG // MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
// SIG // b2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3Nv
// SIG // ZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5u
// SIG // U2hpZWxkIFRTUyBFU046OEQwMC0wNUUwLUQ5NDcxJTAj
// SIG // BgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZp
// SIG // Y2WgghHtMIIHIDCCBQigAwIBAgITMwAAAiorAhXd3Fx0
// SIG // NAABAAACKjANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQG
// SIG // EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
// SIG // BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
// SIG // cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
// SIG // ZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNjAyMTkxOTQwMDla
// SIG // Fw0yNzA1MTcxOTQwMDlaMIHLMQswCQYDVQQGEwJVUzET
// SIG // MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
// SIG // bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
// SIG // aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
// SIG // cGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBF
// SIG // U046OEQwMC0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jv
// SIG // c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqG
// SIG // SIb3DQEBAQUAA4ICDwAwggIKAoICAQDzPfCBALZdNkf5
// SIG // 2bWmCNH/CWVuEUUcOXzDCYR98YuodL3sWlcm1NQjyKSz
// SIG // gLnAC4iWnX+e7eOtEg/poePlCbaxn7DDHIs+C7ApiXeY
// SIG // JnJpDzgoxpWN94QAphh4SYs+rWzZcqtA4q0O0Q+4CXVX
// SIG // lTjIbgNdO0UDlqeM2bI++zEd1rmX46mCPtFo0N9U0d8/
// SIG // PsPEyn1llTU9q7LGVChCz/Q5od8YPzqOT+f4OjBw7PDs
// SIG // KS2D8EzdEpn25ppjrx4lyAGexF87QeWkD1cmTn1SVtjQ
// SIG // XJvj8LVYstVeA/k6Y7IE8ZD1P62BiuQIBrqF7B3Ilddp
// SIG // NelDgnn+5H9XQMoW5rcYh1g1lSh/4/yuulwT2uSufvxI
// SIG // vLV6NGgnl5LlPU0ZlRMHMDzadU5jPcUIQqXK+FlrR966
// SIG // FcWq+UQFcyZPKIJHrKQiyryIr6KcDWp27+ADsHJKMASE
// SIG // 1QBqZfqgQZhmUXmyXZR+cazdJmIsdAJrwrpRXS9E2HIs
// SIG // +FR+xaYB+GVJ9fmtHnTaYT5LNhGURFx02QPpl96817tF
// SIG // GM4vrovYH00qCBuszUALOFADT9VL+1IJoWM9DsRtxWsq
// SIG // E1apM/ou4PII6gQEjP9YtQQmSpUSolpXNk79xE23Ypde
// SIG // dBJs8Gx9T9bqmukezNlpHsc4LBufwdAprRJNWMw0Q2pN
// SIG // fERsj1FT+QIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFBiN
// SIG // f4XD+sZ0GWEhgDttwfhUWzosMB8GA1UdIwQYMBaAFJ+n
// SIG // FV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBS
// SIG // oFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
// SIG // cHMvY3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQ
// SIG // Q0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
// SIG // XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
// SIG // LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGlt
// SIG // ZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1Ud
// SIG // EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
// SIG // DgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4IC
// SIG // AQCbKTsUJNVDrY32V6UTxoOzvAMEMmwQB8Os/umqk5xm
// SIG // johVswdpPcJyxg4nZOgSFuCVdol5EhF6bQcLuJWZDaNI
// SIG // it7zV29rqDS42sgle67tcQWP3IrEIlNh36N9wygQOnue
// SIG // 8NW3UFghGTODnKT3J0oGJ/8MYX9D7gMgpANc3d48WjVZ
// SIG // 0cbscVK7LdeficY+ui9Rsi2JvdG7IfD9GDoSlXgx/qO+
// SIG // 8AnuwF4ZBPNQQzTe0wVifVIDVw0BBDlb1xyx5OsubuOx
// SIG // JMBUcCpJRTImftz8jp80+cnNCoppLeohmJlcAUMDwFqb
// SIG // YvURXCokThtHYFZrUdyj/HiKNHdBVARd44aXAkbiE9KA
// SIG // o13Ldd//CWgiOzUxs73as2j1J3wr7xnS7HzJak5vlqrY
// SIG // HjQ1nGuicmsNJYaCLkEiHJvSQMfXy4oYLFLXDrYMTSz/
// SIG // 6ogSaUF4EtPJbqDT1DxuOXneSCBprO+EsZ4zeY3JcmHv
// SIG // F+r9ZJ5JSNToPNy6Ya/u8U5ftR+/noGjieiXwnvYaBEn
// SIG // T86Iv7hEeIbPlaa5GFDHY9NHhGTSN1oHfTsvXvSXA6V6
// SIG // jw3yZczCLGLe2LxVsdjh5RYJhkX7GeqiIlZgeoWOo8+0
// SIG // Jr+I+hB26BTOc50IjreOrTDBHyyt4wsyrxwBnTfgJV6A
// SIG // CJnw/Dx1Qj6hHNf1kW9Rw+M1UDCCB3EwggVZoAMCAQIC
// SIG // EzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQEL
// SIG // BQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
// SIG // aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
// SIG // ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
// SIG // KU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
// SIG // cml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkz
// SIG // MDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
// SIG // Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
// SIG // BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
// SIG // A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
// SIG // MTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
// SIG // AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
// SIG // yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2
// SIG // Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWG
// SIG // UNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8d
// SIG // q6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/P
// SIG // XfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCO
// SIG // Mcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnop
// SIG // N6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+
// SIG // cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUg
// SIG // fX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj
// SIG // 0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9
// SIG // Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2
// SIG // AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU
// SIG // 2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6
// SIG // r1AFemzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1
// SIG // Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
// SIG // EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
// SIG // FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYE
// SIG // FJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMw
// SIG // UQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0
// SIG // dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9j
// SIG // cy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEF
// SIG // BQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
// SIG // BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
// SIG // HSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNV
// SIG // HR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29m
// SIG // dC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJB
// SIG // dXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBM
// SIG // MEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29m
// SIG // dC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEw
// SIG // LTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9
// SIG // /Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
// SIG // M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
// SIG // OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++
// SIG // Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo
// SIG // 32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5
// SIG // KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3D
// SIG // YXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7
// SIG // T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+
// SIG // CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2z
// SIG // AVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77
// SIG // IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFh
// SIG // bHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGE
// SIG // vL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4
// SIG // JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEz
// SIG // fbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDB
// SIG // cQZqELQdVTNYs6FwZvKhggNQMIICOAIBATCB+aGB0aSB
// SIG // zjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
// SIG // bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
// SIG // FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMc
// SIG // TWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUG
// SIG // A1UECxMeblNoaWVsZCBUU1MgRVNOOjhEMDAtMDVFMC1E
// SIG // OTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
// SIG // cCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQAz8Eo/z8JJ
// SIG // c4wkBjU+FEYBPjSq/aCBgzCBgKR+MHwxCzAJBgNVBAYT
// SIG // AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
// SIG // EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
// SIG // cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
// SIG // LVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA
// SIG // 7pTsmDAiGA8yMDI2MTEwMzIzMjgyNFoYDzIwMjYxMTA0
// SIG // MjMyODI0WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDu
// SIG // lOyYAgEAMAoCAQACAidOAgH/MAcCAQACAhHiMAoCBQDu
// SIG // lj4YAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQB
// SIG // hFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
// SIG // KoZIhvcNAQELBQADggEBAMR+8cmHJONWDRgfDRfVF9+E
// SIG // h/shTUwLmBfNbPlpPAEvTURB+DOlvuAm98MkdZ+T999m
// SIG // wA/oO1KwBSLA02IsbFfc+NkeyfyBoYaEyl6usFsq4y8n
// SIG // 4EWYPRV15zwBVgQH8ft/FfuK4c/yBS6Lq/i5uPMkCul2
// SIG // akkrR3NRk5kysQXzEZyXypiKo5fV1mTT7fdiDRp8ZY2j
// SIG // zjVQnXKvR/BDDb5Ole39qXMExQbya02w1X0QAXSE+UWv
// SIG // kcBsgORMdxU0RCImIZW3fQLdI5wy+eFNgZDQ4oha2q7B
// SIG // It4yfg90tLZSCLdWHULqRvMcHwUewPX+aLC7ObI/ChtH
// SIG // +LGVrND9Un0xggQNMIIECQIBATCBkzB8MQswCQYDVQQG
// SIG // EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
// SIG // BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
// SIG // cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
// SIG // ZS1TdGFtcCBQQ0EgMjAxMAITMwAAAiorAhXd3Fx0NAAB
// SIG // AAACKjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcN
// SIG // AQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEi
// SIG // BCAF0zkhQXwx4pRNlf7fQecoTPFfaXIVCkMYhIoZ5906
// SIG // dzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIMpL
// SIG // g2mURY/WrRXyRt5mfX47Yh2RYxetFfiHOLICI/zlMIGY
// SIG // MIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
// SIG // c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
// SIG // BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
// SIG // AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAC
// SIG // EzMAAAIqKwIV3dxcdDQAAQAAAiowIgQgcjHxfdat6H46
// SIG // Gh6V/QV/Vf6OWOToo8yd7e3vBVgwneYwDQYJKoZIhvcN
// SIG // AQELBQAEggIAe0H2zEkfmBz+8GZbCFVigWn83CggTilj
// SIG // DhOxB3RL/F/rSCPRZs3d12IcPzDq0803ow3yPOKKxHzg
// SIG // VnqmluJ1NTkwQ96AZ5pU1xq2yMXzsfuCn8ljYpXdFOxK
// SIG // xYlmSZVNf4jycJx94uaPBiblSik+UHeFKCnm6JPMJI8t
// SIG // aCYv3aWmKp4ph+TAWg1s4hN+Fd/1wlWDIaZq/mhLRz/1
// SIG // wfOnjf7GRIbleYIYwDTxsqV1DFjqwVwj6iu4t97ONY6K
// SIG // QO8s4w+bbESl//BViKFPwisDkHp28maiMGetEKUtnqIX
// SIG // wTlGb1fjNSk7SQVlLp+S6C4M1LtkzaUh80uPVdaqGj+D
// SIG // bWv3/iVveqj71FhLWeDJtg2Kof7eSnhAM8bZvL4Aqqnp
// SIG // dgWpvXzap3/LZJKBHXs+i7/Xl8Utyq4TTnpjhbtwVIU7
// SIG // 5ouKtdZHAyIAS73tz/yMcrCp9Ww4+kCj0RM7JTPIP/rA
// SIG // sKXHbuPGMaAI8gEJbPj6RbfHzFzsK0s75oudKW6MubT2
// SIG // u/Wv2f3Cz9ku8aIEn3RUNWNFnUn+Kn/IIbmYXommVAvs
// SIG // UJUh8LxUH6xq/8rQMQQ7Mrq62rUgS099oN+IepDs860N
// SIG // BVkgROSf6UQJjbtsgoRJtrHMBQ87riT0uu9LhENYBUzw
// SIG // yXWIXvteYE2F8mvzM4+I85wrX0BpZ5xXRjs=
// SIG // End signature block
