using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class Computer
	{
		public SortedDictionary<string, object> GetCompProps()
		{
            #region Getting  "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" Property from CIM_ComputerSystem Class
            string[] ArrayCompProps = { "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" };            
            var Tmp1CompDetails = HelperFunctions.GetWmiClassDetails("Win32_ComputerSystem", ArrayCompProps);
			#endregion
			

			
			var ComputerProperties = HelperFunctions.PrefixSortedDictionaryKeys(Tmp1CompDetails, "Computer_");
			

			return ComputerProperties;
		}
	}
}
