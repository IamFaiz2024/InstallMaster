using InstallMaster;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace InstallMasterLib
{
	public class HelperFunctions
	{								
        #region Display all Properties of Class
        public static void DisplayObjectProperties(object obj)
        {
            Type type = obj.GetType();
            PropertyInfo[] properties = type.GetProperties();

            foreach (PropertyInfo property in properties)
            {
                object value = property.GetValue(obj, null);
                Console.WriteLine($"{property.Name}: {value}");
            }
        }
		#endregion

		#region Clean the String
		public static string CleanString(object managementObject)
		{
			string targetString = managementObject?.ToString() ?? "Unknown";
			// Remove the "\\.\" prefix
			string cleanString = Regex.Replace(targetString, @"^\\.\\", "");

			// Remove all non-alphanumeric characters
			cleanString = Regex.Replace(cleanString, @"[^a-zA-Z0-9]", " ");

			// Replace double blank spaces with single blank spaces
			cleanString = Regex.Replace(cleanString, @"\s+", " ");

			return cleanString.Trim();
		}
		#endregion
	}
}
