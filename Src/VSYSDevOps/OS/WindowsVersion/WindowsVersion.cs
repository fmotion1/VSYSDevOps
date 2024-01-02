using System;
using Microsoft.Win32;
using System.Data;

namespace VSYSDevOps.OS
{
    public sealed class WindowsVersion
    {
        public string? OSProductName { get; set; }
        public string? OSDisplayVersion { get; set; }
        public string? OSBuildNumber { get; set; }
        public string? OSBuildNumberFull { get; set; }
        public string? OSVersion { get; set; }
        public string? OSVersionCombinedv1 { get; set; }
        public string? OSVersionCombinedv2 { get; set; }
        public string? VersionString { get; set; }

        public WindowsVersion() {

            // string keyPath = @"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion"; 
            // string valueName = "DisplayVersion"; 
            // object displayVersion = Registry.GetValue(keyPath, valueName, null);

            // OSProductName = null;
            // OSDisplayVersion = null;
            // OSBuildNumber = null;
            // OSBuildNumberFull = null;
            // OSVersion = null;
            // OSVersionCombinedv1 = null;
            // OSVersionCombinedv2 = null;
            // VersionString = null;
        }

        // public override string ToString()
        // {
        //     if( OSProductName == null || 
        //         OSDisplayVersion == null || 
        //         OSBuildNumber == null || 
        //         OSBuildNumberFull == null || 
        //         OSVersion == null || 
        //         OSVersionCombinedv1 == null || 
        //         OSVersionCombinedv2 == null ||
        //         VersionString == null
        //     ){
        //         return "Empty";
        //     } else {
        //         return OSVersionCombinedv1;
        //     }
        // }
    }
}
