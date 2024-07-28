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
            

            Device mycomputer = new Device();
            mycomputer.ComputerInfo();

            Motherboard mymotherboard = new Motherboard();
			mymotherboard.MotherboardInfo();


            Console.WriteLine("******************************\n");
            Console.WriteLine("Computer Information");
            HelperFunctions.DisplayObjectProperties(mycomputer);
            
            Console.WriteLine("******************************\n");
            Console.WriteLine("MotherBoard Information");
            HelperFunctions.DisplayObjectProperties(mymotherboard);

            Console.WriteLine("******************************\n");

            Console.ReadLine();
		}
	}
}
