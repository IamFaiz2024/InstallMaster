using InstallMaster;
using InstallMasterLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterConsole
{
	public class Program
	{
		static void Main(string[] args)
		{
			// Test the Motherboard class
			var motherboard = new Motherboard();
            string[] mbProps = { "Manufacturer", "Model", "PartNumber", "Product", "SerialNumber" };
            var motherboardDetails = motherboard.GetMotherboardDetails();
			foreach (var detail in motherboardDetails)
			{
				Console.WriteLine($"{detail.Key}: {detail.Value}");
			}

			Console.ReadLine();
		}
	}	
}
