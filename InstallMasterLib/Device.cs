using InstallMaster;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Management;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
    public class Device
    {
        public string SerialNumber { get; set; } = "Unknown";
		public string CurrentBIOSVersion { get; set; }
        public string Manufacturer { get; set; }
        public string Model { get; set; }
        public string ModelYear { get; set; }
        public string PartNumber { get; set; }
        public string DeviceType { get; set; }
        public string Category { get; set; }

        public void ComputerInfo()
        {
            WMIQuery wmiquery = new WMIQuery();
            this.Category = "Computer";

			var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");
			foreach (var PropDict in wmiProperties)
			{
				if (PropDict.TryGetValue("SMBIOSBIOSVersion", out var biosversion))
				{
					this.CurrentBIOSVersion = biosversion?.ToString() ?? "Unknown";
				}

				if (PropDict.TryGetValue("SerialNumber", out var biosSerialNumber))
				{
					this.SerialNumber = HelperFunctions.CleanString(biosSerialNumber);
					break; // We found the serial number, no need to check Win32_BaseBoard
				}
			}		

			wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_ComputerSystem");
            foreach (var PropDict in wmiProperties)
            {
				if (PropDict.TryGetValue("Description", out var description))
                {
                    this.DeviceType = HelperFunctions.CleanString(description);
                }
                if (PropDict.TryGetValue("SystemSKUNumber", out var partno))
                {
                    this.PartNumber = partno?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
                {
                    this.Manufacturer = HelperFunctions.CleanString(manufacturer);
                }
                if (PropDict.TryGetValue("Model", out var model))
                {
                    this.Model = HelperFunctions.CleanString(model);
                }
            }            

            if (this.SerialNumber.Length <= 2 || this.SerialNumber == "Unknown")
            {
                wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard");
                foreach (var PropDict in wmiProperties)
                {
                    if (PropDict.TryGetValue("SerialNumber", out var mbbSerialNumber))
                    {
                        this.SerialNumber = HelperFunctions.CleanString(mbbSerialNumber);
                        break; // We found the serial number, no need to check Win32_BaseBoard
                    }
                }
            }            
        }
    }
}
