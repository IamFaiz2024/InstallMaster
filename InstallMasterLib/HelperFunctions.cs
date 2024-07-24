using InstallMaster;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class HelperFunctions
	{
		#region Get WMI Class Details
		public static SortedDictionary<string, object> GetWmiClassDetails(string WmiClass, string[] WmiClassProps)
		{
			WMIQuery _wmiQuery = new WMIQuery();
			string StringWmiClassProps = string.Join(",", WmiClassProps);
			string WmiQuery = $"SELECT {StringWmiClassProps} FROM {WmiClass}";
			
			var WmiResults = _wmiQuery.ExecuteWMIQuery(WmiQuery);
			var WmiClassPropsList = new SortedDictionary<string, object>();
			foreach (var WmiResultsItem in WmiResults)
			{
				foreach (var property in WmiResultsItem.Properties) { WmiClassPropsList[property.Name] = property.Value; }
			}
			return WmiClassPropsList;
		}
		#endregion


		#region Combine 2 or more Dictionay/Dictionaries
		public static SortedDictionary<string, object> DictCombiner(params SortedDictionary<string, object>[] dicts)
		{
			var combinedDict = new SortedDictionary<string, object>();
			foreach (var dict in dicts)
			{
				foreach (var itm in dict){combinedDict[itm.Key] = itm.Value;}
			}
			return combinedDict;
		}
		#endregion

		#region Prefix fixed string to all keys in Dictionary
		public static SortedDictionary<string, object> PrefixSortedDictionaryKeys(SortedDictionary<string, object> NonPrefixDictionary, string prefix)
		{
			var NewPrefixDictionary = new SortedDictionary<string, object>();
			foreach (var kvp in NonPrefixDictionary)
			{
				NewPrefixDictionary.Add(prefix + kvp.Key, kvp.Value);
			}
			return NewPrefixDictionary;
		}
		#endregion

		#region Replace a Key in Dictionary
		public static SortedDictionary<string, object>ReplaceDictKey(SortedDictionary<string, object> HostDictionary, string HostString, string TargetString)
		{
			var HostDictValue = HostDictionary[HostString];
			HostDictionary.Remove(HostString);
			HostDictionary.Add(TargetString, HostDictValue);

			return HostDictionary;
		}
		#endregion
	}
}
