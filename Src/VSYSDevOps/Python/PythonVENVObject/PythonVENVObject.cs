namespace VSYSDevOps.Python
{
    public class PythonVENVObject
    {
        public PythonVENVObject() { }
        public string? IsVENV { get; set; }
        public string? PythonVersion { get; set; }
        public string? PythonHome { get; set; }
        public string? VENVPath { get; set; }
        public string? SitePackages { get; set; }
        public string? PythonBinary { get; set; }
        public string? PIPBinary { get; set; }
        public string? IncludeSystemPackages { get; set; }
        public string? ConfigFile { get; set; }
    }
}