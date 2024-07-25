using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class Computer
	{
		public Dictionary<string, object> GetCompProps()
		{
            #region Getting  "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" Property from CIM_ComputerSystem Class
            string[] ArrayCompProps = { "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" };            
            var Tmp1CompDetails = HelperFunctions.GetWmiClassDetails("Computer","Win32_ComputerSystem", ArrayCompProps);
			#endregion


			var ComputerProperties = Tmp1CompDetails;
			//var ComputerProperties = HelperFunctions.PrefixDictionaryKeys(Tmp1CompDetails, "Computer_");


			return ComputerProperties;
		}
	}
}
