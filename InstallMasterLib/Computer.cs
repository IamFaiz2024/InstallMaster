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
	public class Computer
	{
		public string SerialNumber { get; set; }
		public string Manufacturer { get; set; }
		public string Model { get; set; }
		public string ModelYear { get; set; }
		public string PartNumber { get; set; }

		public Computer ComputerInfo()
		{
			Computer computer = new Computer();
			computer.SerialNumber = "ABCD";
			Console.WriteLine(computer.SerialNumber);
			WMIQuery wMIQuery = new WMIQuery();
			var WmiResults = wMIQuery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");
			foreach (var WmiResultsItem in WmiResults)
			{
				foreach (var property in WmiResultsItem.Properties)
				{
					Console.WriteLine($"{property.Name} = {property.Value}");
				}				
			}
			/*
			#region Getting  "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" Property from CIM_ComputerSystem Class
			string[] ArrayCompProps = { "SMBIOSBIOSVersion" };
			var CompDetails = HelperFunctions.GetWmiClassDetails("Win32_BIOS", ArrayCompProps);
            //computer.SerialNumber = CompDetails[SerialNumber];
            foreach (var item in CompDetails)
            {
				Console.WriteLine(item.Value);
            }
            #endregion
			*/


			return computer;
		}
	}
}
