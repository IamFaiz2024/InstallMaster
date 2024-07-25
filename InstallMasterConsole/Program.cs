using InstallMaster;
using InstallMasterLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
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
			#region Test the Motherboard class
			/**/
			var motherboard = new Motherboard();            
            var motherboardDetails = motherboard.GetMBProps();
			Console.WriteLine("***MotherBoard Details***\n");
			foreach (var compdetail in motherboardDetails) {Console.WriteLine($"{compdetail.Key}: {compdetail.Value}");}
            
			#endregion

			#region Test the Computer class
			/*
			var computer = new Computer();
			var computerDetails = computer.GetCompProps();
			Console.WriteLine("***Computer Details***\n");
			foreach (var compdetail in computerDetails) { Console.WriteLine($"{compdetail.Key}: {compdetail.Value}"); }
			*/
			#endregion

			#region Test the Memory Class
			/*
			RAM ram = new RAM();
			var memoryInfoList = ram.GetRAMProps();
			Console.WriteLine("***RAM Details***\n");
			foreach (var ramdetail in memoryInfoList) { Console.WriteLine($"{ramdetail.Key}: {ramdetail.Value}"); }
			*/
			#endregion

			Console.ReadLine();
		}
	}
}
