using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
    public class Motherboard
    {
        public string SerialNumber { get; set; }
        public string Manufacturer { get; set; }
        public string Model { get; set; }
        public string Product { get; set; }
        public string BIOSVersion { get; set; }
        public string Category { get; set; }
        public string CompatibleDevice { get; set; }


        public void MotherboardInfo()
        {
            WMIQuery wmiquery = new WMIQuery();
            this.Category = "Computer";

            var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard");

            foreach (var PropDict in wmiProperties)
            {
                if (PropDict.TryGetValue("SerialNumber", out var srno))
                {
                    this.SerialNumber = HelperFunctions.CleanString(srno);
                }

                if (PropDict.TryGetValue("Model", out var model))
                {
                    this.Model = HelperFunctions.CleanString(model);
                }

                if (PropDict.TryGetValue("Product", out var product))
                {
                    this.Product = HelperFunctions.CleanString(product);
                }

                if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
                {
                    this.Manufacturer = HelperFunctions.CleanString(manufacturer);
                }
            }
            Device computerDevice = new Device();
            computerDevice.ComputerInfo();
            this.CompatibleDevice = computerDevice.Model;

            wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");

            foreach (var PropDict in wmiProperties) 
            {
                if (PropDict.TryGetValue("SMBIOSBIOSVersion", out var biosversion))
                {
                    this.BIOSVersion = HelperFunctions.CleanString(biosversion);
                }
            }

        }
    }
}
