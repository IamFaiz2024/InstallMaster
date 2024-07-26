using InstallMaster;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class HelperFunctions
	{
		#region Get WMI Class Details without component and Instance prefix /**/
		/*
		public static Dictionary<string, object> GetWmiClassDetails(string WmiClass, string[] WmiClassProps)
		{
			WMIQuery _wmiQuery = new WMIQuery();
			string StringWmiClassProps = string.Join(",", WmiClassProps);
			string WmiQuery = $"SELECT {StringWmiClassProps} FROM {WmiClass}";
			
			var WmiResults = _wmiQuery.ExecuteWMIQuery(WmiQuery);
			var WmiClassPropsList = new Dictionary<string, object>();
            //Console.WriteLine($"{WmiResults.Count}");
            foreach (var WmiResultsItem in WmiResults)
			{
				foreach (var property in WmiResultsItem.Properties) { WmiClassPropsList[property.Name] = property.Value; }
			}
			return WmiClassPropsList;
		}
		*/
		#endregion

		#region Get WMI Class Details1
		public static Dictionary<string, object> GetWmiClassDetails(string Component, string WmiClass, string[] WmiClassProps,string Filter=null)
		{
			WMIQuery _wmiQuery = new WMIQuery();
			string StringWmiClassProps = string.Join(",", WmiClassProps);
			string WmiQuery = $"SELECT {StringWmiClassProps} FROM {WmiClass}";

			var WmiResults = _wmiQuery.ExecuteWMIQuery(WmiQuery);
			var WmiClassPropsList = new Dictionary<string, object>();
			#region counter to check if ctrForPropIndex grater than 1 only then prefix InstanceIndex
			/*
			 int instanceIndex = 0;
			 int ctrForPropIndex = 0;
			 foreach (var WmiResultsItem in WmiResults)
			{
				ctrForPropIndex++;
			}

            if (ctrForPropIndex > 1) 
            {
				foreach (var WmiResultsItem in WmiResults)
				{
					string instancePrefix = $"{Component}{instanceIndex + 1}_";

					foreach (var property in WmiResultsItem.Properties)
					{
						WmiClassPropsList[$"{instancePrefix}{property.Name}"] = property.Value;
					}
					instanceIndex++;
				}			
			}
            else
            {
				foreach (var WmiResultsItem in WmiResults)
				{
					foreach (var property in WmiResultsItem.Properties) { WmiClassPropsList[$"{instancePrefix}{property.Name}"] = property.Value; }
				}
			}*/
			#endregion
			#region Prefix Component and Intance /**/
			/*
			int instanceIndex = 0;
			foreach (var WmiResultsItem in WmiResults)
			{
				string instancePrefix = $"{Component}{instanceIndex + 1}_";

				foreach (var property in WmiResultsItem.Properties)
				{
					WmiClassPropsList[$"{instancePrefix}{property.Name}"] = property.Value;
				}
				instanceIndex++;
			}
			*/
			#endregion
			
			return WmiClassPropsList;
		}
		#endregion

		#region Get WMI Class Details2
		public static Dictionary<string, object> GetWmiClassDetails(string WmiClass, string[] WmiClassProps, string Filter = null)
		{
			WMIQuery _wmiQuery = new WMIQuery();
			string StringWmiClassProps = string.Join(",", WmiClassProps);
			string WmiQuery = $"SELECT {StringWmiClassProps} FROM {WmiClass}";

			var WmiResults = _wmiQuery.ExecuteWMIQuery(WmiQuery);
			var WmiClassPropsList = new Dictionary<string, object>();
			
			return WmiClassPropsList;
		}


		#endregion

		#region Combine 2 or more Dictionay/Dictionaries
		public static Dictionary<string, object> DictCombiner(params Dictionary<string, object>[] dicts)
		{
			var combinedDict = new Dictionary<string, object>();
			foreach (var dict in dicts)
			{
				foreach (var itm in dict) { combinedDict[itm.Key] = itm.Value; }
			}
			return combinedDict;
		}
		#endregion

		#region Prefix fixed string to all keys in Dictionary
		public static Dictionary<string, object> PrefixDictionaryKeys(Dictionary<string, object> NonPrefixDictionary, string prefix)
		{
			var NewPrefixDictionary = new Dictionary<string, object>();
			foreach (var kvp in NonPrefixDictionary)
			{
				NewPrefixDictionary.Add(prefix + kvp.Key, kvp.Value);
			}
			return NewPrefixDictionary;
		}
		#endregion

		#region Replace a Key in Dictionary
		public static Dictionary<string, object> ReplaceDictKey(Dictionary<string, object> HostDictionary, string HostString, string TargetString)
		{
			/*
			 foreach (var key in dict.Keys)
			{
				if (key.Contains(wildcard))
				{
					Console.WriteLine($"Key: {key}, Value: {dict[key]}");
				}
			}	
			 */
			var HostDictValue = HostDictionary[HostString];
			HostDictionary.Remove(HostString);
			HostDictionary.Add(TargetString, HostDictValue);

			return HostDictionary;
		}
		#endregion

		#region Getting WMI Results from ManagementObjectSearcher /**/ 
		/*
			ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PhysicalMemory");
			// Iterate over the results and print the properties
			foreach (ManagementObject obj in searcher.Get())
			{
				Console.WriteLine("--------------------");
				foreach (PropertyData prop in obj.Properties)
				{
					Console.WriteLine($"{prop.Name}: {prop.Value}");
				}
			}
			*/
		#endregion

	}
}
