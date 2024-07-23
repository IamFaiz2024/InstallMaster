using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace InstallMasterLib
{
	public class HelperFunctions
	{
		public static Dictionary<string, object> DictCombiner(params Dictionary<string, object>[] dicts)
		{
			var combinedDict = new Dictionary<string, object>();
			foreach (var dict in dicts)
			{
				foreach (var itm in dict){combinedDict[itm.Key] = itm.Value;}
			}
			return combinedDict;
		}

		public static Dictionary<string, object> PrefixDictionaryKeys(Dictionary<string, object> dictionary, string prefix)
		{
			return dictionary.ToDictionary(kvp => prefix + kvp.Key, kvp => kvp.Value);
		}
	}
}
