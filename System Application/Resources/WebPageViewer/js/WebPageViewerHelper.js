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
// SIG // hrzT4aeocEidJtWlFnZ0el78HeuKzeUoXt9/RzAlG7mg
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
// SIG // SIb3DQEJBDEiBCD+BYy7aI2jZ8rDyymfmlaFFuZkOoo0
// SIG // uwUCu4m3QXdOmTBCBgorBgEEAYI3AgEMMTQwMqAUgBIA
// SIG // TQBpAGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5t
// SIG // aWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAIFx
// SIG // MOXAeNIApeZ7Rxhlmr46+/qnT2vrEh0c8rG+3x7bwDUP
// SIG // aPly4DYtDcHO27CeqTjA5KkMNFsKf8YJZyhj0wUs+LHW
// SIG // jY8d9PxPLp8wBk22kEk25PHP0P+MHojj7Ks5eFAVG2XF
// SIG // BzxSIJ3zp0ItMU/HqtDRpYvzd7ZMmTpmZyPV7fi+Vk9U
// SIG // /YmXm/6IvOtFoFZMHP5vXn+gSQKyMJP5sj9qPhvLo/ol
// SIG // ms5jVpEDUwHojxeYKeq13JZqZHyHjwZ8QVN77soTV/p6
// SIG // K919Lc0gQcBb8AsJ8/oXlLEk8DBjANYWlmtbfFT+jKOh
// SIG // ahD9Z3my8DOJG8S3UWWoP2JmYqn/9FehgheUMIIXkAYK
// SIG // KwYBBAGCNwMDATGCF4Awghd8BgkqhkiG9w0BBwKgghdt
// SIG // MIIXaQIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBUgYLKoZI
// SIG // hvcNAQkQAQSgggFBBIIBPTCCATkCAQEGCisGAQQBhFkK
// SIG // AwEwMTANBglghkgBZQMEAgEFAAQg50zkDeiyEgZ1OCFr
// SIG // NMY2q4oY5y4AsiVqP/VJWf/9HpoCBmqqLfHkTBgTMjAy
// SIG // NjEwMDQyMjAwNTcuOTA2WjAEgAIB9KCB0aSBzjCByzEL
// SIG // MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
// SIG // EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
// SIG // c29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9z
// SIG // b2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMe
// SIG // blNoaWVsZCBUU1MgRVNOOjg5MDAtMDVFMC1EOTQ3MSUw
// SIG // IwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
// SIG // aWNloIIR6jCCByAwggUIoAMCAQICEzMAAAIiQdL2qv/I
// SIG // tf8AAQAAAiIwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UE
// SIG // BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
// SIG // BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
// SIG // b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
// SIG // bWUtU3RhbXAgUENBIDIwMTAwHhcNMjYwMjE5MTkzOTU2
// SIG // WhcNMjcwNTE3MTkzOTU2WjCByzELMAkGA1UEBhMCVVMx
// SIG // EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
// SIG // ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
// SIG // dGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2Eg
// SIG // T3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1Mg
// SIG // RVNOOjg5MDAtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNy
// SIG // b3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkq
// SIG // hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtbniibpCLlLA
// SIG // ACaPwGOQ2Uah+24YL+wlhjZRHW0RqCE63ROlrJ+ezWjb
// SIG // tQU3YwWxXL+0X4sbXtMfh0b10qrA/lnkl/+v8vcBNDM/
// SIG // sUT0xiGNtCu2kA2uvDss1clHlAsqcmQv4Fv98rTv2Tp1
// SIG // PR9q4u+5CT/AAa6sstVMV/zrHhILx7I/MopFk9AEba41
// SIG // m1zBxc0jqOYUHH1JjFyqlls+vjdPlMp4RstZ/naFuFmY
// SIG // KR/GOVu4aUqJFo9TPy7uMIt6Og8/b1VrpHIFBRoywJeG
// SIG // GaToWoex7ogv2pVyJjEH/AtwPKv+v9YRaHiGQeFBpMsM
// SIG // QfzkkzkrC+vt/aQ6szOwoDqX+Fe/fZDfeMjPblySOU/0
// SIG // ogOTHSGSIRFtPm4fOUag4eWFt/6Gr+eET8cOTj5R+uEF
// SIG // eiiZJdBSBJTFaCzaPFFkUHDA9e/ce1gEowui7GjWe8it
// SIG // KnBEiLC9cIkJnX0AcXKqxQqSEH55kBZDqfSMl1Fqs2vL
// SIG // Zqc/BOml4PW9XogE9z1U4KzpT4v4WGQnz8V/+oxrcj48
// SIG // tQosDpiWpqIZklP/wjgHp30U9hthzEVKQl9c7PgJg5nU
// SIG // DNV0Wm+GEgCywJQ8xgrICO+557iY6FwJYiZr+zX671gH
// SIG // AOSqglDlkOpEj7ea9vDHyl1iSaUl7RXkvzJA8ycv4iUV
// SIG // ch3BcvwfjLcCAwEAAaOCAUkwggFFMB0GA1UdDgQWBBRZ
// SIG // B8BqAyeWWxBIrvCrLYrrKmqM0DAfBgNVHSMEGDAWgBSf
// SIG // pxVdAF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSg
// SIG // UqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
// SIG // b3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIw
// SIG // UENBJTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBe
// SIG // MFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29m
// SIG // dC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRp
// SIG // bWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNV
// SIG // HRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
// SIG // MA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOC
// SIG // AgEAYgDPp6q6cBtvbcUl7+NqPgrE3tguG6GkXxY7vSWl
// SIG // pC0x8Ku6ZJzTjS95/lBt8fwdPNxCl4hWKwJrpewUxwhl
// SIG // 1Ot/8UbGdsI92ZkdAOHfZ3/bGgiVZuI7j1RQWov6JLTj
// SIG // mB9o/tfszO9MKDeaJ4Af6b8u1/AH2OiQeFz72/NEM+32
// SIG // OXnXW58I84NbGYVDxW23MHlngAiDa86hSutpjHlypobb
// SIG // nzK2qKICXiV31mN8eP6W7m4BDU9/qV0+udtNwjxfZH3S
// SIG // hOxigCEWMt8ZAUw7xXfHbn4zqQp9/JyuqjJVbZwYw4Vk
// SIG // BtDzNxP6MQbOVAayOqQWJJiB7W44nw6rh0/k4WlVe8R3
// SIG // OiJ6EnN2jc1+PSR1IEJrrw3TIy5G2F3gNP9auSMUoNlP
// SIG // snGQTrwIt7nWTyoQOVczg43/7nLv7xbV62HEZJhijd47
// SIG // o2it/8jGYtibuTRC9yElqK8Ke0Y3mYPiTCCtH6LLlY/m
// SIG // Apua+uCx/w/UCQwI/l32WjXhXb/dCuQNEEURj/6aAfck
// SIG // yFYxF4/7ic6fC+A3eOLAKrqgzoh3ZC4MXyvJz6qQklj2
// SIG // fRvkQj5vOaPXAH8RDba0rjsHKcis8bEQmAi/jyuPvfKK
// SIG // 4rfRFSfyy6Anhvoy5Y9Cmg+EMurGXuK1jK9W60C6LEwW
// SIG // TcBZ18TYyJwlgXdIu4rNck0v+KkwggdxMIIFWaADAgEC
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
// SIG // BgNVBAsTHm5TaGllbGQgVFNTIEVTTjo4OTAwLTA1RTAt
// SIG // RDk0NzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh
// SIG // bXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAu8nF1Wcd
// SIG // 27A6SZK+1bnIKZLKM7iggYMwgYCkfjB8MQswCQYDVQQG
// SIG // EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
// SIG // BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
// SIG // cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
// SIG // ZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQsFAAIF
// SIG // AO5tDUwwIhgPMjAyNjEwMDQxNzM3MTZaGA8yMDI2MTAw
// SIG // NTE3MzcxNlowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA
// SIG // 7m0NTAIBADAHAgEAAgIfiTAHAgEAAgIVejAKAgUA7m5e
// SIG // zAIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZ
// SIG // CgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqG
// SIG // SIb3DQEBCwUAA4IBAQCycjWqW1m5wcNHwhhlj2fYI75W
// SIG // t3blP/jLAagQnHyLKnphuFKBdDgIBe3WKOfU52XhYiLo
// SIG // KoJIMX8LMR4YlTGqdfwLzL7LKX5bQAPJvtbI9xmhq7ti
// SIG // 9cJhQYi9BPHxF+gz/Wrp+mLxJqaYgAIneJwVWOoSmkLP
// SIG // +VB1IN6C3BFD3dF7g4k4Wg9gG4g1y3VjVSTikgt1Pmil
// SIG // KiTI669qWvxL1ULbRIurpNPnY51bokzRVhEBCBrKZyw9
// SIG // x8FWlyJXCwGzKUf+AWU7DyG7xinMTgsH5IaKmyBgNOZ8
// SIG // IBoFKf+dNrgoF8K0YIOQBttIgbdA4KujL8eNiStNEPdM
// SIG // KwabfO6tMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMC
// SIG // VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
// SIG // B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
// SIG // b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
// SIG // U3RhbXAgUENBIDIwMTACEzMAAAIiQdL2qv/Itf8AAQAA
// SIG // AiIwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJ
// SIG // AzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQg
// SIG // UTnfczSEkteG0ADavUHi4WFrxqLGS7+yhSRNowfd9vcw
// SIG // gfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAFYF0B
// SIG // CgTnxoIzbJJgzpm3BCDpxxjcAPkHEbnw0eQJEzCBmDCB
// SIG // gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
// SIG // aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
// SIG // ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
// SIG // HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
// SIG // AAACIkHS9qr/yLX/AAEAAAIiMCIEIMANvDFKmE60rlbL
// SIG // uctNmQF2dMV2pypDoKzo0lJXaO/HMA0GCSqGSIb3DQEB
// SIG // CwUABIICABm6O1e8o4kLxqRNDGYKeAQvoVHFJ4/es5ZB
// SIG // Ux1LY0N5lNUCrwZ/CHGjaUnmwGlyn9GyQJp1y9b0TUaC
// SIG // 2dhZNYVe9tyWqntTzwnB62mcTaUg5/6cIrp2F7RZcE2z
// SIG // LLq362FqjGftP8pbJ78//1u7o2MSvFwFxMG0oanyj0W3
// SIG // 0H2aJNaDuwm8DXsx/9KRFjhNyex9TZSWFmjrt+LIfnH/
// SIG // 5O83mz84luh13rfkg+VJMVFUbIP+ptV89183N+5/q0Cl
// SIG // /lzvjYdPR1aa1fpKZ83cjGeugr0b0zVzALaOXLwihsfR
// SIG // imB2g1WiVqQ6mLTi38dV2aDwV85RjNfQ6K4Y8A37Uj9O
// SIG // cMwqiRarWfMmRgKpuVAc2E478VxF9JSMHI+SwFE1keg9
// SIG // 7j2vHQ6K15K6jSb8j/QRt35iu4Hw+WDeMboXTClxXUGZ
// SIG // V1gni/qNqglis1QY6xQ7ecqduUwcOKwEP33Pj0liFCA+
// SIG // DMX2elB2o/fK4LFJMvvQPSOLjZoiTgcFWdLfSnccz35W
// SIG // 7yV+/dj2sU6ZP7DGjOFqk9DO1C2RFw47VNhpcREZRX50
// SIG // fNDWoj//x9D4nT0ER2Sc1NohTEHRldQfda2gH+8hUDOU
// SIG // Pm3a+A5YPKFiDWmgYv+oC18f+MhLtv69+yamnGk66pB2
// SIG // fmKJ6/PBhxW4j/jyNW6L0dSPz39Bggo+
// SIG // End signature block
