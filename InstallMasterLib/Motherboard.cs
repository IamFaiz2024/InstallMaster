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
            #region Get mbDetails for MotherBoard
            string mbquery = "SELECT Manufacturer,Model,PartNumber,Product,SerialNumber FROM Win32_BaseBoard";
			var mbresults = _wmiQuery.ExecuteWMIQuery(mbquery);
			var mbDetails = new Dictionary<string, object>();
			foreach (var item in mbresults)
			{
				foreach (var property in item.Properties)
				{
					mbDetails[property.Name] = property.Value;
				}
			}
            #endregion
            #region GetbiosSR from Bios.cs
            /*
            var _bios = new Bios();
            string[] biosSrProp = { "SMBIOSBIOSVersion" };
            var biosSR = _bios.GetBios(biosSrProp);
            */
            #region if searching for SMBIOSBIOSVersion here
            /*
            var _biosdetails = _bios.GetBIOSDetails();
			Dictionary<string, object> biosSR = _biosdetails
            .Where(entry => entry.Key == "SMBIOSBIOSVersion")
            .ToDictionary(entry => entry.Key, entry => entry.Value);
			*/
            #endregion
            #endregion

            //combine MotherBoard and Bios SR Number
            var motherboardDetail = CombineWithBiosDetails(mbDetails);

            //return mbDetails;
            return motherboardDetail;
        }

        public Dictionary<string, object> GetMotherboardDetails(string[] filterItem)
        {
            string filterItemString = string.Join(", ", filterItem);
            string mbquery = $"SELECT {filterItem} FROM Win32_BIOS";
            var mbresults = _wmiQuery.ExecuteWMIQuery(mbquery);
            var mbDetails = new Dictionary<string, object>();
            foreach (var item in mbresults)
            {
                foreach (var property in item.Properties)
                {
                    mbDetails[property.Name] = property.Value;
                }
            }

            //combine MotherBoard and Bios SR Number
            var motherboardDetail = CombineWithBiosDetails(mbDetails);

            //return mbDetails;
            return motherboardDetail;            
        }

        private Dictionary<string, object> CombineWithBiosDetails(Dictionary<string, object> mbDetails)
        {
            var _bios = new Bios();
            string[] biosSrProp = { "SMBIOSBIOSVersion" };
            var biosSR = _bios.GetBios(biosSrProp);
            var motherboardDetail = mbDetails.Concat(biosSR).ToDictionary(pair => pair.Key, pair => pair.Value);

            return motherboardDetail;
        }
    }
}
