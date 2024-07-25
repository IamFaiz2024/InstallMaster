using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
    public class RAM
    {
		public Dictionary<string, object> GetRAMProps()
		{
			#region Getting "Manufacturer", "Model", "PartNumber", "Product", "SerialNumber" Property from Win32_BaseBoard Class
			string[] ArrayRamProps = { "DeviceLocator", "SerialNumber", "Capacity ", "BankLabel", "Speed", "MemoryType", "Manufacturer", "PartNumber" };
			var RamDetails = HelperFunctions.GetWmiClassDetails("RAM","Win32_PhysicalMemory", ArrayRamProps);
			#endregion

			return RamDetails;
		}
	}
}
