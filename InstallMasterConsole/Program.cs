using InstallMaster;
using InstallMasterLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Remoting.Channels;
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
            var motherboardDetails = motherboard.GetMBProps();
			Console.WriteLine("***MotherBoard Details***\n");
			foreach (var mbbdetail in motherboardDetails) {Console.WriteLine($"{mbbdetail.Key}: {mbbdetail.Value}");}
			Console.ReadLine();
		}
	}	
}
