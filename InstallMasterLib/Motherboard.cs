using InstallMaster;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class Motherboard
	{
		private WMIQuery _wmiQuery;
		private Bios _Bios;


		public Motherboard()
		{
			_wmiQuery = new WMIQuery();
			_Bios = new Bios();
		}

		public Dictionary<string, object> GetMotherboardDetails()
		{
			# region Getting Result for MotherBoard
			string mbquery = "SELECT * FROM Win32_BaseBoard";
			var mbresults = _wmiQuery.ExecuteWMIQuery(mbquery);
			var motherboardDetails = new Dictionary<string, object>();
			foreach (var item in mbresults)
			{
				foreach (var property in item.Properties)
				{
					motherboardDetails[property.Name] = property.Value;
				}
			}
			#endregion

			var _bios = new Bios();
			var _biosdetails = _bios.GetBIOSDetails();
			Dictionary<string, object> _biosSR = _biosdetails.Where(kvp => kvp.Key == "SMBIOSBIOSVersion")
											  .ToDictionary(kvp => kvp.Key, kvp => kvp.Value);

			var mergedDetails = motherboardDetails.Concat(_biosSR).ToDictionary(pair => pair.Key, pair => pair.Value);

			return motherboardDetails;
		}				
	}
}
