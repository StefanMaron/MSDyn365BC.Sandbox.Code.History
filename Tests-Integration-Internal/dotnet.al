// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Integration.Office.Mock")
    {
        Culture = 'neutral';
        PublicKeyToken = 'ebb8d478f63174c0';

        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.Mock.OutlookMessageFactoryMock"; "OutlookMessageFactoryMock")
        {
        }

        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.Mock.OutlookMessageMock"; "OutlookMessageMock")
        {
        }
    }

    assembly("MockTest")
    {
        type("MockTest.MockHttpResponse.MockHttpMessageHandler"; "MockHttpMessageHandler")
        {
        }
    }
}