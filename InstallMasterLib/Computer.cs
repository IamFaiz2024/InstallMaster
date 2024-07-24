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
			#region Getting "Manufacturer", "Model", "PartNumber", "Product", "SerialNumber" Property from CIM_ComputerSystem Class
			string[] ArrayMbProps = { "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" };
			var Tmp1CompDetails = HelperFunctions.GetWmiClassDetails("CIM_ComputerSystem", ArrayMbProps);
			#endregion

			/*
			#region Getting "SMBIOSBIOSVersion" from Win32_BIOS Class
			string[] ArrayBiosSrNo = { "SMBIOSBIOSVersion" };
			var TmpBiosSrNo = HelperFunctions.GetWmiClassDetails("Win32_BIOS", ArrayBiosSrNo);
			#endregion

			//Replacing Key "SMBIOSBIOSVersion" to "BiosVersion"
			var BiosSrNo = HelperFunctions.ReplaceDictKey(TmpBiosSrNo, "SMBIOSBIOSVersion", "BiosVersion");

			//Combining Dictionary BiosSrNo and Tmp1MbDetails(Motherboard Details)
			var Tmp2MbDetails = HelperFunctions.DictCombiner(Tmp1MbDetails, BiosSrNo);
			*/

			//Adding Prefix MotherBoard_ to each Property
			var MotherboardProperties = HelperFunctions.PrefixSortedDictionaryKeys(Tmp1CompDetails, "MotherBoard_");
			

			return MotherboardProperties;
		}
	}
}
