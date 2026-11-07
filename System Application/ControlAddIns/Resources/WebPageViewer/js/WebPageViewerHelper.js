/*! Copyright (C) Microsoft Corporation. All rights reserved. */

var WebPageViewerHelper = {
    Initialize: function () {
      if (WebPageViewerHelper.IsRunningOnIos()) {
        // Do not add the spinner in iOS, as this might cause rendering issues for the iframe
        return;
      }
      var spinnerSrc = Microsoft.Dynamics.NAV.GetImageResource('Loader.gif');
      var spinnerContainer = document.createElement('div');
      spinnerContainer.setAttribute('id', 'spinner');
  
      var spinner = document.createElement('img');
      spinner.setAttribute('src', spinnerSrc);
  
      spinnerContainer.appendChild(spinner);
  
      document.body.insertBefore(spinnerContainer, document.body.childNodes[0]);
    },
  
    DisplaySpinner: function () {
      var spinner = document.getElementById('spinner');
      if (spinner != null) {
        spinner.setAttribute('style', 'display: block');
      }
  
      var content = document.getElementById('controlAddIn');
      content.display = 'none';
    },
  
    HideSpinner: function () {
      var spinner = document.getElementById('spinner');
      if (spinner != null) {
        spinner.setAttribute('style', 'display: none');
      }
  
      var content = document.getElementById('controlAddIn');
      content.display = 'block';
    },
  
    CreateIFrame: function (height, width) {
      WebPageViewerHelper.DisplaySpinner();
  
      var iframe = document.createElement('iframe');
      iframe.setAttribute('height', height);
      iframe.setAttribute('width', width);
      iframe.setAttribute('frameBorder', '0');
      iframe.setAttribute('seamless', 'seamless');
      iframe.setAttribute('role', 'presentation');
  
      return iframe;
    },
  
    IFrameReady: function (iframe, callback) {
      var contentLoadedEvent = function () {
        WebPageViewerHelper.HideSpinner();
        iframe.removeEventListener('load', contentLoadedEvent);
      };
  
      var poll = setInterval(function () {
        try {
          if (iframe.contentDocument && iframe.contentDocument.body) {
            iframe.addEventListener('load', contentLoadedEvent);
  
            iframe.contentDocument.body.setAttribute('style', 'margin: 0px; padding: 0px;');
  
            var event = {
              preventLoadEvent: function () {
                iframe.removeEventListener('load', contentLoadedEvent);
              }
            };
  
            callback(event);
  
            clearInterval(poll);
          }
        }
        catch (ex) {
          clearInterval(poll);
        }
      }, 5);
    },
  
    CreateInput: function (name, value) {
      var input = document.createElement('input');
      input.setAttribute('type', 'hidden');
      input.setAttribute('name', name);
      input.setAttribute('value', value);
  
      return input;
    },
  
    CreateFormWithData: function (method, action, data) {
      if (!(method.toUpperCase() === "GET" || method.toUpperCase() === "POST")) {
        throw 'Unsupported Method Specified';
      }
  
      if (action.substring(0, 8).toLowerCase() !== "https://") {
        throw 'Insecure URL Specified';
      }
  
      var form = document.createElement('form');
      form.setAttribute('method', method);
      form.setAttribute('action', action);
  
      for (var key in data) {
        // decode posted data as it will be re-encoded on submit by the browser
        var input = WebPageViewerHelper.CreateInput(decodeURIComponent(key), decodeURIComponent(data[key]));
  
        form.appendChild(input);
      }
  
      return form;
    },
  
    RunJavascript: function (js, documentContext) {
      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.text = js;
      documentContext.head.appendChild(script);
    },
  
    SetBodyContent: function (content) {
      var controlAddIn = window.document.getElementById('controlAddIn');
      controlAddIn.innerHTML = '';
      controlAddIn.appendChild(content);
  
      // For elastic scrolling to work on iOS we need to apply
      // a few styles on the DOM element that is hosting the 
      // iframe element.
      if (WebPageViewerHelper.IsRunningOnIos()) {
        controlAddIn.classList.add('ms-dyn-nav-scrollable');
      }
  
      WebPageViewerHelper.Properties.BodyContent = content;
    },
  
    GetCallbackURL: function () {
      var proto = document.location.protocol;
      var host = document.location.host;
      var path = Microsoft.Dynamics.NAV.GetImageResource('Callback.html');
  
      if (host == '') { // on phone client the host is empty
        return path;
      }
  
      if (path.indexOf(proto + '//') == 0) {
        // assume path already contains host information
        return path;
      } else {
        // need to specify host information
        return proto + '//' + host + path;
      }
    },
  
    TriggerCallback: function (data) {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Callback', [data]);
    },
  
    ChildDocumentReady: function () {
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DocumentReady');
    },
  
    TriggerEvent: function (data) {
      var target = WebPageViewerHelper.Properties.BodyContent;
      if (!(target && target.contentWindow)) {
        return;
      }
  
      var event;
      if (!target.contentDocument.createEvent) {
        event = new CustomEvent('webpageviewerevent', data);
      } else {
        event = target.contentDocument.createEvent('CustomEvent');
        event.initEvent('webpageviewerevent', true, true);
        event.data = data;
      }
  
      window.dispatchEvent(event);
    },
  
    LinksOpenInNewWindow: function () {
      var targetDocument = WebPageViewerHelper.Properties.BodyContent;
      if (!targetDocument || !targetDocument.contentDocument) {
        return;
      }
  
      targetDocument = targetDocument.contentDocument;
      var links = targetDocument.getElementsByTagName('a');
  
      for (var i = 0; i < links.length; i++) {
        if (links[i].hasAttribute('href')) {
          (function () {
            var url = links[i].getAttribute('href');
            links[i].setAttribute('href', '#');
            links[i].addEventListener('click', function (e) {
              Microsoft.Dynamics.NAV.OpenWindow(url);
              e.preventDefault();
            });
          })();
        }
      }
    },
  
    UpdateLinks: function () {
      if (WebPageViewerHelper.Properties.LinksOpenInNewWindow) {
        WebPageViewerHelper.LinksOpenInNewWindow();
      }
    },
  
    SetCallbacksFromSubscribedEventToIgnore: function (eventName, callbackResults) {
      WebPageViewerHelper.Properties.IgnoreCallbacks[eventName] = callbackResults;
    },
  
    SubscribeToEvent: function (eventName, recieveMessage) {
      if (WebPageViewerHelper.Properties.SubscribedEvents.indexOf(eventName) < 0) {
        WebPageViewerHelper.Properties.SubscribedEvents.push(eventName);
        window.addEventListener(eventName, recieveMessage);
      }
    },
  
    HandleException: function (ex) {
      var errMsg = ex + '.';
      var helpMsg = 'Please contact your system administrator.';
  
      var container = document.createElement('div');
  
      var h1 = document.createElement('h1');
      var h2 = document.createElement('h2');
  
      if (container.textContent === '') {
        h1.textContent = errMsg;
        h2.textContent = helpMsg;
      } else {
        h1.innerText = errMsg;
        h2.innerText = helpMsg;
      }
  
      container.appendChild(h1);
      container.appendChild(h2);
  
      WebPageViewerHelper.SetBodyContent(container);
    },
  
    IsRunningOnIos: function () {
      return WebPageViewerHelper.FindInUserAgentString('IPAD') || WebPageViewerHelper.FindInUserAgentString('IPOD') || WebPageViewerHelper.FindInUserAgentString('IPHONE');
    },
  
    FindInUserAgentString: function (targetString) {
      return WebPageViewerHelper.GetUserAgentString().indexOf(targetString) > -1;
    },
  
    GetUserAgentString: function () {
      if (WebPageViewerHelper.Properties.UserAgentString == null) {
        WebPageViewerHelper.Properties.UserAgentString = window.navigator.userAgent.toUpperCase();
      }
  
      return WebPageViewerHelper.Properties.UserAgentString;
    },
    
    /// <summary>
    /// Creates a subscription function for an iframe that notifies any subscribers after the load event occurs and the src attribute is set. 
    /// </summary>
    /// <param name="iframe">The iframe to trigger the load event from.</param>
    /// <returns type="function">Subscription function that adds subscribers to the load event.</returns>
    BindSrcLoadEvent: function (iframe) {

  
      var loaded = false;
      var subscriptions = [];
  
      // Checks to see if the iframe has loaded and if the src attribute has been set
      var srcLoadEvent = function () {
        if (iframe.src) {
          iframe.removeEventListener('load', srcLoadEvent);
          loaded = true;
  
          // Notify all subscribers that the load event has occured with the src attribute set
          for (var i = 0; i < subscriptions.length; i++) {
            subscriptions[i]();
          }
        }
      }
  
      // Hook up the actual load event listener
      iframe.addEventListener('load', srcLoadEvent);
  
      // Return a subscription function that allows consumers to subscribe to the load event at any time
      return function (subscriber) {
        if (typeof subscriber === 'function' && subscriptions.indexOf(subscriber) < 0) {
          subscriptions.push(subscriber); // Always add the subscriber to the subscriptions list
          if (loaded) subscriber(); // Notify the subscriber immediately if already loaded
        }
      };
    },
  
    Properties: {
      BodyContent: null,
      LinksOpenInNewWindow: false,
      UserAgentString: null,
      SubscribedEvents: [],
      IgnoreCallbacks: {}
    }
  };
// SIG // Begin signature block
// SIG // MIInRAYJKoZIhvcNAQcCoIInNTCCJzECAQExDzANBglg
// SIG // hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
// SIG // BgEEAYI3AgEeMCQCAQEEEBDgyQbOONQRoqMAEEvTUJAC
// SIG // AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
// SIG // U2IMD2WpSHXpRBtfZyRv63rWuahFXv1yGqWSu8VgylWg
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
// SIG // JkDeVuJ9dNXGNi+AOxk0BtYd9hxwL30BElj9MYIZ4jCC
// SIG // Gd4CAQEwbjBXMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
// SIG // TWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9N
// SIG // aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDI0AhMz
// SIG // AAACHU0ZyE7XD1dIAAAAAAIdMA0GCWCGSAFlAwQCAQUA
// SIG // oIGuMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
// SIG // CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
// SIG // SIb3DQEJBDEiBCBuE8Wvr/aHjZBP7Gu3iI8xI+8tO41F
// SIG // 7NFvarGJrt2m5TBCBgorBgEEAYI3AgEMMTQwMqAUgBIA
// SIG // TQBpAGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5t
// SIG // aWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAKgA
// SIG // /qZsxae0SIdFyFd21BRIWEVbHGXbhpfJtvmwgRROf7bI
// SIG // VzNMn8YjFJvKGaH2cr8r8tOCZ87styXT54SBvN3HY/Qx
// SIG // 5ynp/0KGeFP0rsHsNqekIgr/uokrtouyel+9M3vzvzGx
// SIG // TLurIpPP7o49vRYfoyFp1Y2L975/JFOHeS9iPJeUOJQA
// SIG // emxa3QUbrX/ww3ayGAErxRAPorqSs1AmEi2xbgLy9wDs
// SIG // WSQ37HalxZKMRm2qM35iti+/51UkeJpzC38J+JD5y2/L
// SIG // A37TuipTnMeDHbq31LG+uwDSELbDNkfDeA9EpcMRDmAt
// SIG // ats2aagCQkexfujwlFdEbJpBVBtptEOhgheUMIIXkAYK
// SIG // KwYBBAGCNwMDATGCF4Awghd8BgkqhkiG9w0BBwKgghdt
// SIG // MIIXaQIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUgYLKoZI
// SIG // hvcNAQkQAQSgggFBBIIBPTCCATkCAQEGCisGAQQBhFkK
// SIG // AwEwMTANBglghkgBZQMEAgEFAAQgAGfNLkJrzZB6+DYp
// SIG // RQwO8GZgijwadSbO5tyO3/SHxzICBmq39mKjjxgTMjAy
// SIG // NjExMDYxNjUzMzMuNjg2WjAEgAIB9KCB0aSBzjCByzEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9z
// SIG // b2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMe
// SIG // blNoaWVsZCBUU1MgRVNOOjMzMDMtMDVFMC1EOTQ3MSUw
// SIG // IwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
// SIG // aWNloIIR6jCCByAwggUIoAMCAQICEzMAAAIhM8A1+9IP
// SIG // IaQAAQAAAiEwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UE
// SIG // BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
// SIG // BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
// SIG // b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
// SIG // bWUtU3RhbXAgUENBIDIwMTAwHhcNMjYwMjE5MTkzOTU0
// SIG // WhcNMjcwNTE3MTkzOTU0WjCByzELMAkGA1UEBhMCVVMx
// SIG // EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
// SIG // ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
// SIG // dGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2Eg
// SIG // T3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1Mg
// SIG // RVNOOjMzMDMtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNy
// SIG // b3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkq
// SIG // hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA23EwAqlNWL0a
// SIG // HMli9jy/X8n//lC7Nqiu1NWmbEZw2Up5Qq+yu44AN3hQ
// SIG // hCS+QWe3VEwtA3mXqX/mQvuxxGweCHc5iX0AFAxRXq6m
// SIG // OVUx5kLz9lwN5VkhY++NInXBlB4JT+R/z2wiVOxgB1j9
// SIG // h3XAo3cdZWAKNAPsyyO8cJ00HjMjl19tdhIOFJgzzyYM
// SIG // XUzMOlhVVrAT1kQYuYA4sctrPu0fAA5OZWwQRQweYdAo
// SIG // 6zViDe7ggMxeYO7a6y/J1yCqddJo/UcYXBkPrZYbelSL
// SIG // 3coEVU1BncxQdv5wbyakPZMcRZbUEk+9HxHceE8miqMP
// SIG // 3+fgUoeM+P/X+zVyFVUy5//JHCQH0ahZka6xbdyCm8u1
// SIG // a85mLqEFg9JZjRbRkOewayZD6zxQD3pNQC7XG2+xR950
// SIG // Kb4vJ4M/zBV//nJ5jRVhVNvVVS5swfV7y2cW2L5Hnrbd
// SIG // JoeZX7XnjdqxMFMq3ayrn8/YdkuqW2rXvgtodNgq18Ep
// SIG // GtMens6U5hpCCSxbdubm/1GFzS3R3bMRg+hH3JDiKCWL
// SIG // JuDEvRf70qizRyvPSNL0ywZ4EBKeiyBZCDWp0U9z7Tcd
// SIG // 6TSkSiUQC3Oi+poVuIS+Ghy++Paj30O9reagDJucYimD
// SIG // ICdlmp4nUSzbiNudSSDe62mngP9r29FxZGXCG00daX0B
// SIG // rHKOFNIObY8CAwEAAaOCAUkwggFFMB0GA1UdDgQWBBTm
// SIG // IyLOamuqX7qrj8sitRU6+UAwpzAfBgNVHSMEGDAWgBSf
// SIG // pxVdAF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSg
// SIG // UqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
// SIG // b3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIw
// SIG // UENBJTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBe
// SIG // MFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29m
// SIG // dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
// SIG // bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNV
// SIG // HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
// SIG // MA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOC
// SIG // AgEAOCP925HZ08Q9qxbptzBfMVSnRJKIQDm23j60PtH6
// SIG // +W0Ypo8/bFZCk/+4HI+DjHApUmBviHV+jKdxGLCx1n47
// SIG // 8H8xaHmRPsk23QY/9VR2UEbgpsOkKnlQk28Np50u5wcZ
// SIG // 1nfaGV2z1KahGsB+Q6l0GlhYEfQOCllSvyL11QzI9T5T
// SIG // whEtT9yaJzW3YZJJM+PaybijpuW+3vwR/JaKgJlzl0XN
// SIG // tssVlUzFqxKeKbJZr/Hk+1aGPF/43SmEz1RF7H5i21RX
// SIG // KszLgfLxRn1MlrFkTkvMIKu5UGH1nGKoezcpqAE1/sFm
// SIG // Ct81hu2kXIjxlAM8513X/mh7SFp0CzWuRxZkl5ImpN30
// SIG // rqa1mGYh4bmIxNeoa6AKXAR6ZvvEv5DaoZvVo0F/tgcZ
// SIG // 2L/iXo8upak4vHywS0tOvVl1cP6bX+SFfhbWJd+Br1aH
// SIG // oN9VKFJlVWXtUg1CZJvXQ13PJf6gQ2IgCE9ggrD08rfV
// SIG // wPSVbh8XT+t5+wob1gDv+O0Ebgg7FJRSaFsMgcJe43mK
// SIG // WkVTLULdIriTBho4BGiV9UP9o/LF1Eb03Hixww/YqVrd
// SIG // PdmQ1jEHIg0ZoRzRTl9XZ4wb5P5NVDHIPfe4+aGM5wJ0
// SIG // qSb5YP+AT92lRNIf2B9ioLCm1ODV2RwIyV49kpaqNQtd
// SIG // eQhuqgWWhZDPFurz2Qpuap0nszowggdxMIIFWaADAgEC
// SIG // AhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEB
// SIG // CwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
// SIG // aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
// SIG // ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQD
// SIG // EylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
// SIG // b3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5
// SIG // MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
// SIG // EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
// SIG // HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
// SIG // BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
// SIG // MDEwMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
// SIG // AgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51
// SIG // yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64
// SIG // NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1
// SIG // hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmv
// SIG // Haus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoP
// SIG // z130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1w
// SIG // jjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56
// SIG // KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7
// SIG // vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2l
// SIG // IH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUD
// SIG // o9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz1dhz
// SIG // PUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtco
// SIG // dgLiMxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGU
// SIG // lNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsl
// SIG // uq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W2
// SIG // 9R6HXtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZ
// SIG // MBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUC
// SIG // BBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQW
// SIG // BBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBT
// SIG // MFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNo
// SIG // dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0Rv
// SIG // Y3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYB
// SIG // BQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEw
// SIG // CwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
// SIG // VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
// SIG // VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3Nv
// SIG // ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2Vy
// SIG // QXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4w
// SIG // TDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3Nv
// SIG // ZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAx
// SIG // MC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1V
// SIG // ffwqreEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9
// SIG // MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulm
// SIG // ZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pv
// SIG // vinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbz
// SIG // aN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3
// SIG // +SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsId
// SIG // w2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5m
// SIG // O0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ
// SIG // /gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9
// SIG // swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu
// SIG // +yFUa2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyh
// SIG // YWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+pTFR
// SIG // hLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0
// SIG // +CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAx
// SIG // M328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQ
// SIG // wXEGahC0HVUzWLOhcGbyoYIDTTCCAjUCAQEwgfmhgdGk
// SIG // gc4wgcsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
// SIG // aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
// SIG // ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsT
// SIG // HE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAl
// SIG // BgNVBAsTHm5TaGllbGQgVFNTIEVTTjozMzAzLTA1RTAt
// SIG // RDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh
// SIG // bXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAC2xIGWZ8
// SIG // mB1ydQxm+Xxo6ZV6bbmggYMwgYCkfjB8MQswCQYDVQQG
// SIG // EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
// SIG // BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
// SIG // cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
// SIG // ZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsFAAIF
// SIG // AO6YeqIwIhgPMjAyNjExMDYxNjExMTRaGA8yMDI2MTEw
// SIG // NzE2MTExNFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA
// SIG // 7ph6ogIBADAHAgEAAgIuTzAHAgEAAgISWzAKAgUA7pnM
// SIG // IgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZ
// SIG // CgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqG
// SIG // SIb3DQEBCwUAA4IBAQAvO5zbYpdNaOOjSXraaX1+rnKe
// SIG // mqORaMW6fwF5U3OEm7WfsL6/jFukM5qji5u3KcNxFvf3
// SIG // nUq079DPkU4W+jQIPCqNlaKvCdu/6KZE/bsnxjCMlktt
// SIG // h42GoDEGphicdDJk6JuYYpslhlHm1ShuxRO6zYzbrLM7
// SIG // QN7e7Tu1hU1eG9KudeBp50Ahp9Ku6T281BizJaW54pjW
// SIG // 7xoSP5pXLaAcOULAXGyHWOnnQUaX9n9F693gBj67v3HT
// SIG // eZOJwGiSHFhjUdEOwj7VzEr5/gq6UYZ5JR89o+rchdK5
// SIG // KWuvYPZAdCtnrSjDXARy70Lj3eV/h2CK2g07mz6G/bm4
// SIG // 3FbX3SmcMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
// SIG // VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
// SIG // B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
// SIG // b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
// SIG // U3RhbXAgUENBIDIwMTACEzMAAAIhM8A1+9IPIaQAAQAA
// SIG // AiEwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJ
// SIG // AzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQg
// SIG // KgepxOZ7wKSTo8oXpNt1NPvLuQpCtwLKnPD/2LnigE4w
// SIG // gfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAA7yEH
// SIG // nxVVGuAScvCGcsDAL5hkinVFahJsvQPvjwo9RDCBmDCB
// SIG // gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
// SIG // aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
// SIG // ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
// SIG // HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
// SIG // AAACITPANfvSDyGkAAEAAAIhMCIEIN/LDcUCwHY21CUC
// SIG // acSATGZFFK/F5jAcIYuqAMTDRVbWMA0GCSqGSIb3DQEB
// SIG // CwUABIICAGZZWzukrRrrVG1UZFEgPUClJ8eu+DXsjmbH
// SIG // Mcpkk2546+EjW6b5TZXvfJvIxNYUk53vvAnMdhPQQ5YZ
// SIG // t133d34bXtENLozVKreK/en4ZTgSWUQWN7dX22c5St4i
// SIG // TDMOG28yon7jPXMOObJ8l71EqydEAZLllGGJGXcK3COj
// SIG // 4gCp8bs0x0J1omJ221R7lusKtH4FrzayuDYF3lGY1NN5
// SIG // Ig2kl5crLVN0WTuOwF0pklq+RBShJZyVhANGkItunLxF
// SIG // r+CDqh3S4fbyefHw7jTmoV1gmKs3zf4HHaXwJFk/Cdzb
// SIG // MdnaDJvtUMfAPYbvbybP4YC/lYDDE2fiRQmZ5HbKn4rX
// SIG // W1za9u9f3OFPFIUfYLq4OdVzvJZf+RDW+LjijWyWwFnj
// SIG // YwuMTkqQw1XGTWkVmxiPd1rOA2uhkHhot7AxQ+ZfyeCn
// SIG // eHPiXoqK7co/bVOJgsPlR/QQhLeN6ZG39jIdRVAP4prK
// SIG // UOqH1dBzIRD2MYVBBlQFk5R9f/LyBINOxVESuEw86B3V
// SIG // PDD+eqczoDF55eSjHAmLrgZEi9Rqxl2WxSoHA1WuoJ3w
// SIG // pdm6mPyCSiWfVp5ScdH208MdcEtqge2LkGTT3bqoK0Nb
// SIG // DV8LS+c7fHKjrm/BZUmNNzB19quAUkUMd5bncEGpWpNl
// SIG // NHLfV3v2dEI+fujZ9KRph60zMUQsthHI
// SIG // End signature block
