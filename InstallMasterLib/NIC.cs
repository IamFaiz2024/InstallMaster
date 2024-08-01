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

	public class NIC
	{
		public string MACAddress { get; set; }
		public string Model { get; set; }
		public string Manufacturer { get; set; }
		public string ConnectionType { get; set; }
		public string CompatibleDevice { get; set; }
	}

	public class NetworkAdapterManager
	{
		public List<NIC> NICs { get; set; }

		public void NetworkInfo()
		{
			WMIQuery wmiquery = new WMIQuery();
			this.NICs = new List<NIC>();

			// Populate the Memory information
			var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_NetworkAdapter WHERE PhysicalAdapter = 'True'");
			foreach (var PropDict in wmiProperties)
			{
				var nic = new NIC();

				if (PropDict.TryGetValue("MACAddress", out var macAddress))
				{
					nic.MACAddress = macAddress?.ToString() ?? "Unknown";
				}
				if (PropDict.TryGetValue("Description", out var description))
				{
					nic.Model = HelperFunctions.CleanString(description);
				}
				if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
				{
					nic.Manufacturer = HelperFunctions.CleanString(manufacturer);
				}
				if (PropDict.TryGetValue("NetConnectionID", out var netconnectionid))
				{
					nic.ConnectionType = HelperFunctions.CleanString(netconnectionid);
				}

				Device computerDevice = new Device();
				computerDevice.ComputerInfo();
				nic.CompatibleDevice = computerDevice.Model;

				this.NICs.Add(nic);
			}

			// Expose the Memory properties individually
			foreach (var nic in NICs)
			{
				Console.WriteLine($"MAC Address: {nic.MACAddress}");
				Console.WriteLine($"Model: {nic.Model}");
				Console.WriteLine($"Manufacturer: {nic.Manufacturer}");
				Console.WriteLine($"Connection Type: {nic.ConnectionType}");
				Console.WriteLine($"Compatible Device: {nic.CompatibleDevice}");
				Console.WriteLine();
			}
		}
	}
}
