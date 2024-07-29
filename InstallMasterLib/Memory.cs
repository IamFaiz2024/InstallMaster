using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
    public class Memory
    {
        public string SerialNumber { get; set; }
        public string Model { get; set; }
        public string Manufacturer { get; set; }
        public string PartNumber { get; set; }        
        public string Speed { get; set; }
        public string Capacity { get; set; }
        public string MemoryType { get; set; }
        public string CompatibleDevice { get; set; }
    }

    public class MemoryManager
    {
        public List<Memory> MEMs { get; set; }

        public void MemoryInfo()
        {
            WMIQuery wmiquery = new WMIQuery();
            this.MEMs = new List<Memory>();

            // Populate the Memory information
            var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_PhysicalMemory");
            foreach (var PropDict in wmiProperties)
            {
                var mem = new Memory();

                if (PropDict.TryGetValue("SerialNumber", out var serialnumber))
                {
                    mem.SerialNumber = HelperFunctions.CleanString(serialnumber); ;
                }
                if (PropDict.TryGetValue("Model", out var model))
                {
                    mem.Model = HelperFunctions.CleanString(model); ;
                }
                if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
                {
                    mem.Manufacturer = HelperFunctions.CleanString(manufacturer); 
                }
                if (PropDict.TryGetValue("PartNumber", out var partnumber))
				{
					mem.PartNumber = partnumber?.ToString() ?? "Unknown";//HelperFunctions.CleanString(partnumber);
				}
                if (PropDict.TryGetValue("Capacity", out var capacity))
                {
                    mem.Capacity = HelperFunctions.CleanString(capacity);
				}
                if (PropDict.TryGetValue("ConfiguredClockSpeed", out var configuredclockspeed))
                {
                    mem.Speed = HelperFunctions.CleanString(configuredclockspeed);
				}

                Device computerDevice = new Device();
                computerDevice.ComputerInfo();
                mem.CompatibleDevice = computerDevice.Model;

                this.MEMs.Add(mem);
            }
            // Expose the Memory properties individually
            foreach (var mem in MEMs)
            {
                Console.WriteLine($"SerialNumber: {mem.SerialNumber}");
                Console.WriteLine($"Model: {mem.Model}");
                Console.WriteLine($"Manufacturer: {mem.Manufacturer}");
                Console.WriteLine($"PartNumber: {mem.PartNumber}");
                Console.WriteLine($"CompatibleDevice: {mem.CompatibleDevice}");
                Console.WriteLine($"Speed: {mem.Speed}");
                Console.WriteLine($"Capacity: {mem.Capacity}");
                Console.WriteLine($"CMemoryType: {mem.MemoryType}");                
                Console.WriteLine();
            }
        }
    }
}
