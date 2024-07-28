using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
    public class Storage
    {
        public string SerialNumber { get; set; }
        public string Model { get; set; }
        public string Manufacturer { get; set; }
        public string DeviceID { get; set; }
        public string MediaType { get; set; }
        public string Capacity { get; set; }
        public string InterfaceType { get; set; }
        public string CompatibleDevice { get; set; }

    }

    public class StorageManager
    {
        public List<Storage> Storages { get; set; }

        public void StorageInfo()
        {
            WMIQuery wmiquery = new WMIQuery();
            this.Storages = new List<Storage>();

            var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_DiskDrive");
            foreach (var PropDict in wmiProperties)
            {
                var storage = new Storage();

                if (PropDict.TryGetValue("SerialNumber", out var serialnumber))
                {
                    storage.SerialNumber = serialnumber?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("Model", out var model))
                {
                    storage.Model = model?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
                {
                    storage.Manufacturer = manufacturer?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("DeviceID", out var deviceid))
                {
                    storage.DeviceID = deviceid?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("MediaType", out var mediatype))
                {
                    storage.MediaType = mediatype?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("Size", out var capacity))
                {
                    storage.Capacity = capacity?.ToString() ?? "Unknown";
                }
                if (PropDict.TryGetValue("InterfaceType", out var interfacetype))
                {
                    storage.InterfaceType = interfacetype?.ToString() ?? "Unknown";
                }

                Device computerDevice = new Device();
                computerDevice.ComputerInfo();
                storage.CompatibleDevice = computerDevice.Model;

                this.Storages.Add(storage);
            }

            foreach (var storage in Storages)
            {
                Console.WriteLine($"SerialNumber: {storage.SerialNumber}");
                Console.WriteLine($"Model: {storage.Model}");
                Console.WriteLine($"Manufacturer: {storage.Manufacturer}");
                Console.WriteLine($"DeviceID: {storage.DeviceID}");
                Console.WriteLine($"MediaType: {storage.MediaType}");
                Console.WriteLine($"Capacity: {storage.Capacity}");
                Console.WriteLine($"InterfaceType: {storage.InterfaceType}");                
                Console.WriteLine();
            }
        }
    }
}
