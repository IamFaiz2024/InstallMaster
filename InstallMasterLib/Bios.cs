﻿using InstallMaster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class Bios
	{
		private WMIQuery _wmiQuery;

		public Bios()
		{
			_wmiQuery = new WMIQuery();
		}

		public Dictionary<string, object> GetBIOSDetails()
		{
			string biosquery = "SELECT * FROM Win32_BIOS";
			var biosresults = _wmiQuery.ExecuteWMIQuery(biosquery);
			var biosbiosDetail = new Dictionary<string, object>();
			foreach (var item in biosresults)
			{
				foreach (var property in item.Properties)
				{
					biosbiosDetail[property.Name] = property.Value;
				}
			}
			return biosbiosDetail;
		}
	}
}
