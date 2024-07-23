using System;
using System.Collections.Generic;
using System.Management;

namespace InstallMaster
{
	public class WMIQuery
	{
		public IEnumerable<ManagementBaseObject> ExecuteWMIQuery(string query)
		{
			var result = new List<ManagementBaseObject>();

			try
			{
				using (var searcher = new ManagementObjectSearcher(query))
				{
					foreach (var item in searcher.Get()){result.Add(item);}
				}
			}
			catch (ManagementException ex){	Console.WriteLine($"Error executing WMI query: {ex.Message}");}
			catch (Exception ex){Console.WriteLine($"Error: {ex.Message}");}
			return result;
		}
    }
}