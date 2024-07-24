using InstallMaster;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class Motherboard
	{		

		public SortedDictionary<string, object> GetNewMBProps()
		{
			#region Getting "Manufacturer", "Model", "PartNumber", "Product", "SerialNumber" Property from Win32_BaseBoard Class
			string[] ArrayMbProps = { "Manufacturer", "Model", "PartNumber", "Product", "SerialNumber" };
			var Tmp1MbDetails = HelperFunctions.GetWmiClassDetails("Win32_BaseBoard", ArrayMbProps);
			#endregion

			# region Getting "SMBIOSBIOSVersion" from Win32_BIOS Class
			string[] ArrayBiosSrNo = { "SMBIOSBIOSVersion" };
			var TmpBiosSrNo = HelperFunctions.GetWmiClassDetails("Win32_BIOS", ArrayBiosSrNo);
			#endregion

			//Replacing Key "SMBIOSBIOSVersion" to "BiosVersion"
			var BiosSrNo = HelperFunctions.ReplaceDictKey(TmpBiosSrNo, "SMBIOSBIOSVersion", "BiosVersion");

			//Combining Dictionary BiosSrNo and Tmp1MbDetails(Motherboard Details)
			var Tmp2MbDetails = HelperFunctions.DictCombiner(Tmp1MbDetails, BiosSrNo);

			//Adding Prefix MotherBoard_ to each Property
			var MotherboardProperties = HelperFunctions.PrefixSortedDictionaryKeys(Tmp2MbDetails, "MotherBoard_");

			return MotherboardProperties;
		}
    }
}
