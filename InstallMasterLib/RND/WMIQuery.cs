using System;
using System.Collections.Generic;
using System.Management;

namespace InstallMaster
{
	public class WMIQuery
	{
        #region New Way

        public List<Dictionary<string, object>> ExecuteWMIQuery(string query)
        {
            var result = new List<Dictionary<string, object>>();

            try
            {
                using (var searcher = new ManagementObjectSearcher(query))
                {
                    foreach (var item in searcher.Get())
                    {
                        var properties = new Dictionary<string, object>();
                        foreach (PropertyData property in item.Properties)
                        {                           
                            properties.Add(property.Name, property.Value);
                        }
                        result.Add(properties);
                    }
                }
            }
            catch (ManagementException ex)
            {
                Console.WriteLine($"Error executing WMI query: {ex.Message}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
            return result;
        }

        #endregion
    }
}