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
		private WMIQuery _wmiQuery;
		private Bios _Bios;

		public Motherboard()
		{
			_wmiQuery = new WMIQuery();
			_Bios = new Bios();			
		}

		public Dictionary<string, object> GetMotherboardDetails()
		{
            #region Get mbDetails for MotherBoard
            string mbquery = "SELECT * FROM Win32_BaseBoard";
			var mbresults = _wmiQuery.ExecuteWMIQuery(mbquery);
			var mbDetails = new Dictionary<string, object>();
			foreach (var item in mbresults)
			{
				foreach (var property in item.Properties){mbDetails[property.Name] = property.Value;}
			}
            #endregion     
            //return mbDetails;
            return mbDetails;
        }

        public Dictionary<string, object> GetMotherboardDetails(string[] filterItem)
		{
            string filterItemString = string.Join(",", filterItem);
			string mbquery = $"SELECT {filterItemString} FROM Win32_BaseBoard";
			Debug.WriteLine(mbquery);
            var mbresults = _wmiQuery.ExecuteWMIQuery(mbquery);
            var mbDetails = new Dictionary<string, object>();
            foreach (var mbbitem in mbresults)
            {
                foreach (var property in mbbitem.Properties){mbDetails[property.Name] = property.Value;}
            }

			string[] biosSrProp = { "SMBIOSBIOSVersion" };
			var biosSR = _Bios.GetBiosSR(biosSrProp);

			//combine MotherBoard and Bios SR Number
			var motherboardDetail = HelperFunctions.DictCombiner(mbDetails, biosSR);

            //return mbDetails;
            return motherboardDetail;            
        }        
    }
}
