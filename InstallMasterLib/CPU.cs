using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class CPU
	{
		public string SerialNumber { get; set; }
		public string Model { get; set; }
		public string Manufacturer { get; set; }		
		public string SocketType { get; set; }
		public string CPUDeviceID { get; set; }
		public string CompatibleDevice { get; set; }
	}

	public class CPUManager
	{
		public List<CPU> CPUs { get; set; }

		public void CPUInfo()
		{
			WMIQuery wmiquery = new WMIQuery();
			this.CPUs = new List<CPU>();

			// Populate the Memory information
			var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_Processor");
			foreach (var PropDict in wmiProperties)
			{
				var cpu = new CPU();

				if (PropDict.TryGetValue("ProcessorId", out var processorid))
				{
					cpu.SerialNumber = HelperFunctions.CleanString(processorid);
				}
				if (PropDict.TryGetValue("DeviceID", out var deviceid))
				{
					cpu.CPUDeviceID = deviceid?.ToString() ?? "Unknown";
				}
				if (PropDict.TryGetValue("Name", out var name))
				{
					cpu.Model = name?.ToString() ?? "Unknown";
				}
				if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
				{
					cpu.Manufacturer = HelperFunctions.CleanString(manufacturer);
				}
				if (PropDict.TryGetValue("SocketDesignation", out var socketdesignation))
				{
					cpu.SocketType = HelperFunctions.CleanString(socketdesignation);
				}				

				Device computerDevice = new Device();
				computerDevice.ComputerInfo();
				cpu.CompatibleDevice = computerDevice.Model;

				this.CPUs.Add(cpu);
			}

			// Expose the Memory properties individually
			foreach (var cpu in CPUs)
			{
				Console.WriteLine($"SerialNumber: {cpu.SerialNumber}");
				Console.WriteLine($"Model: {cpu.Model}");
				Console.WriteLine($"Manufacturer: {cpu.Manufacturer}");
				Console.WriteLine($"SocketType: {cpu.SocketType}");
				Console.WriteLine($"CompatibleDevice: {cpu.CompatibleDevice}");				
				Console.WriteLine();
			}
		}
	}
}
