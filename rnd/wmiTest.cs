#region Test the Motherboard class
/*
var motherboard = new Motherboard();            
var motherboardDetails = motherboard.GetMBProps();
Console.WriteLine("***MotherBoard Details***\n");
foreach (var compdetail in motherboardDetails) {Console.WriteLine($"{compdetail.Key}: {compdetail.Value}");}
*/
#endregion

#region Test the Computer class
/*
var computer = new Device();
var computerDetails = computer.GetCompProps();
Console.WriteLine("***Device Details***\n");
foreach (var compdetail in computerDetails) { Console.WriteLine($"{compdetail.Key}: {compdetail.Value}"); }
*/
#endregion

#region Test the Memory Class
/*
RAM ram = new RAM();
var memoryInfoList = ram.GetRAMProps();
Console.WriteLine("***RAM Details***\n");
foreach (var ramdetail in memoryInfoList) { Console.WriteLine($"{ramdetail.Key}: {ramdetail.Value}"); }
*/
#endregion


#region Old Working 
/*
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
 */
#endregion




 WMIQuery wMI = new WMIQuery();

 var wmiProperties = wMI.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");
 wmiProperties.AddRange(wMI.ExecuteWMIQuery("SELECT * FROM Win32_OperatingSystem"));
 wmiProperties.AddRange(wMI.ExecuteWMIQuery("SELECT * FROM Win32_PhysicalMemory"));

 foreach (var propertyDict in wmiProperties)
 {
     foreach (var property in propertyDict)
     {
         Console.WriteLine($"{property.Key} = {property.Value}");
     }
     Console.WriteLine();
 }


//**********************************************************************************************************


 WMIQuery wMI = new WMIQuery();

var wmiProperties = wMI.ExecuteWMIQuery("SELECT * FROM Win32_PhysicalMemory");
wmiProperties.AddRange(wMI.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard"));
wmiProperties.AddRange(wMI.ExecuteWMIQuery("SELECT * FROM Win32_ComputerSystemProduct"));

Console.WriteLine("Hardware Serial Numbers:");

foreach (var propertyDict in wmiProperties)
{
    if (propertyDict.TryGetValue("SerialNumber", out var serialNumber))
    {
        if (propertyDict.ContainsKey("MemoryType"))
        {
            Console.WriteLine($"RAM Serial Number: {serialNumber}");
        }
        else if (propertyDict.ContainsKey("Manufacturer"))
        {
            Console.WriteLine($"Motherboard Serial Number: {serialNumber}");
        }
        else if (propertyDict.ContainsKey("UUID"))
        {
            Console.WriteLine($"Computer Serial Number: {serialNumber}");
        }
    }
}



//***********************************************************

 WMIQuery wMIQuery = new WMIQuery();

 var WmiResults = wMIQuery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");

 foreach (var WmiResultsItem in WmiResults)
 {
     using (WmiResultsItem)
     {
         string serialNumber = (string)WmiResultsItem.Properties["SerialNumber"].Value;
         Console.WriteLine($"Serial Number: {serialNumber}");
     }
 }


 //************************************************************************

 foreach (var WmiResultsItem in WmiResults)
{
    foreach (var property in WmiResultsItem.Properties)
    {
        Console.WriteLine($"{property.Name} = {property.Value}");
    }
}

 #region Getting  "Name", "Caption", "Manufacturer", "Model", "SystemSKUNumber", "SystemType" Property from CIM_ComputerSystem Class
 string[] ArrayCompProps = { "SMBIOSBIOSVersion" };
 var CompDetails = HelperFunctions.GetWmiClassDetails("Win32_BIOS", ArrayCompProps);
 //computer.SerialNumber = CompDetails[SerialNumber];
 foreach (var item in CompDetails)
 {
     Console.WriteLine(item.Value);
 }
 #endregion


 //*****************************************************


 public class Computer
{
	public string SerialNumber { get; set; }
	public string Manufacturer { get; set; }
	public string Model { get; set; }
	public string ModelYear { get; set; }
	public string PartNumber { get; set; }
    public string DeviceType { get; set; }

    public Computer ComputerInfo()
    {
        Computer computer = new Computer();

        WMIQuery wmiquery = new WMIQuery();

        string biosSRNO =null;
        string mbbSRNO = null;
        string compsysSRNo = null;

        var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_ComputerSystem");
        wmiProperties.AddRange(wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS"));
        wmiProperties.AddRange(wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard"));

        foreach (var PropDict in wmiProperties)
        {
            if (PropDict.TryGetValue("Caption", out var cmpserialNumber))
            {
                compsysSRNo = cmpserialNumber.ToString();
                Console.WriteLine($"Serial Number From ComputerSystem Class: {compsysSRNo}");
            }

                if (PropDict.TryGetValue("SerialNumber", out var serialNumber))
            {
                if (PropDict.ContainsKey("BiosCharacteristics"))
                {
                    Console.WriteLine($"Serial Number From BIOS Class: {serialNumber}");
                    biosSRNO = (serialNumber).ToString();
                }
                if (PropDict.ContainsKey("Product"))
                {
                    Console.WriteLine($"Serial Number From Motherboard Class: {serialNumber}");
                    //computer.SerialNumber = serialNumber.ToString();
                    biosSRNO = (serialNumber).ToString();
                }
            }

            //if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
            //{
            //    Console.WriteLine($"Manufacturer: {manufacturer}");
            //    computer.Manufacturer = manufacturer.ToString();
            //}

            //if (PropDict.TryGetValue("Model", out var model))
            //{
            //    Console.WriteLine($"Model: {model}");
            //    computer.Model = model.ToString();
            //}

            //if (PropDict.TryGetValue("SystemSKUNumber", out var partno))
            //{
            //    computer.Model = partno.ToString();
            //}
            if (PropDict.TryGetValue("Description", out var devicetype))
            {
                computer.DeviceType = devicetype.ToString();
            }
        }

        return computer;
    }
}




    if (PropDict.TryGetValue("SerialNumber", out var serialNumber))
{
    if (PropDict.ContainsKey("BiosCharacteristics"))
    {
        Console.WriteLine($"Serial Number From BIOS Class: {serialNumber}");
        biosSRNO = (serialNumber).ToString();
    }
    if (PropDict.ContainsKey("Product"))
    {
        Console.WriteLine($"Serial Number From Motherboard Class: {serialNumber}");
        //computer.SerialNumber = serialNumber.ToString();
        biosSRNO = (serialNumber).ToString();
    }


    **********************************************************

    wmiProperties.AddRange(wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS"));
wmiProperties.AddRange(wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard"));

foreach (var PropDict in wmiProperties)
{
    if (PropDict.TryGetValue("Caption", out var cmpserialNumber))
    {                    
        Console.WriteLine($"Serial Number From ComputerSystem Class: {compsysSRNo}");
        compsysSRNo = cmpserialNumber.ToString();
    }
    if (PropDict.TryGetValue("SerialNumber", out var serialNumber))
    {
        if (PropDict.ContainsKey("BiosCharacteristics"))
        {
            Console.WriteLine($"Serial Number From BIOS Class: {serialNumber}");
            biosSRNO = (serialNumber).ToString();
        }
        if (PropDict.ContainsKey("Product"))
        {
            Console.WriteLine($"Serial Number From Motherboard Class: {serialNumber}");
            mbbSRNO = (serialNumber).ToString();
        }
    }
}



******************************************************************************
if (device.SerialNumber.Length <= 2)
{
    wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");
    foreach (var PropDict in wmiProperties)
    {
        if (PropDict.TryGetValue("SerialNumber", out var biossrno))
        {
            //Console.WriteLine($"Serial Number From BIOS Class: {biossrno}");
            device.SerialNumber = biossrno.ToString();
        }
    }
}


if (device.SerialNumber == null)
{
    wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard");
    foreach (var PropDict in wmiProperties)
    {
        if (PropDict.TryGetValue("SerialNumber", out var mbsrrno))
        {
            //Console.WriteLine($"Serial Number From BaseBoard Class: {mbsrrno}");
            device.SerialNumber = mbsrrno.ToString();
        }
    }
}

****************************************************************

public class Device
{
	public string SerialNumber { get; set; }
	public string Manufacturer { get; set; }
	public string Model { get; set; }
	public string ModelYear { get; set; }
	public string PartNumber { get; set; }
    public string DeviceType { get; set; }
    public string Category { get; set; }

    public Device ComputerInfo()
    {
        Device device = new Device();

        WMIQuery wmiquery = new WMIQuery();
        device.Category = "Computer";            

        var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_ComputerSystem");
        foreach (var PropDict in wmiProperties)
        {
            if (PropDict.TryGetValue("Caption", out var caption))
            {
                //caption = "";
                //Console.WriteLine($"Serial Number From ComputerSystem Class: {caption}");                   
                device.SerialNumber = caption.ToString();
            }
            if (PropDict.TryGetValue("Description", out var description))
            {
                //Console.WriteLine($"DeviceType ComputerSystem Class: {description}");
                device.DeviceType = $"{description.ToString()} Computer";
            }
            if (PropDict.TryGetValue("SystemSKUNumber", out var partno))
            {
                //Console.WriteLine($"PartNumber ComputerSystem Class: {partno}");
                device.PartNumber = partno.ToString();
            }
            if (PropDict.TryGetValue("Manufacturer", out var manufacturer))
            {
                //Console.WriteLine($"Manufacturer ComputerSystem Class: {manufacturer}");
                device.Manufacturer = manufacturer.ToString();
            }
            if (PropDict.TryGetValue("Model", out var model))
            {
                //Console.WriteLine($"Model ComputerSystem Class: {model}");
                device.Model = model.ToString();
            }
        }
        return device;
    }
}



*************************************************************************************

public void ComputerInfo()
{
    WMIQuery wmiquery = new WMIQuery();
    this.Category = "Computer";

    try
    {
        // Try to get the serial number from CIM_ComputerSystem
        var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_ComputerSystem");
        if (wmiProperties.Any())
        {
            this.SerialNumber = wmiProperties[0].GetValueOrDefault("Caption", "Unknown");
        }
    }
    catch
    {
        // If CIM_ComputerSystem fails, try to get the serial number from Win32_BIOS
        try
        {
            var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BIOS");
            if (wmiProperties.Any())
            {
                this.SerialNumber = wmiProperties[0].GetValueOrDefault("SerialNumber", "Unknown");
            }
        }
        catch
        {
            // If Win32_BIOS fails, try to get the serial number from Win32_BaseBoard
            try
            {
                var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard");
                if (wmiProperties.Any())
                {
                    this.SerialNumber = wmiProperties[0].GetValueOrDefault("SerialNumber", "Unknown");
                }
            }
            catch
            {
                // If all attempts fail, set SerialNumber to "Unknown"
                this.SerialNumber = "Unknown";
            }
        }
    }

    // Populate other properties only if the serial number was found
    if (this.SerialNumber != "Unknown")
    {
        var wmiProperties = wmiquery.ExecuteWMIQuery("SELECT * FROM CIM_ComputerSystem");
        if (wmiProperties.Any())
        {
            this.DeviceType = $"{wmiProperties[0].GetValueOrDefault("Description", "Unknown")} Computer";
            this.PartNumber = wmiProperties[0].GetValueOrDefault("SystemSKUNumber", "Unknown");
            this.Manufacturer = wmiProperties[0].GetValueOrDefault("Manufacturer", "Unknown");
            this.Model = wmiProperties[0].GetValueOrDefault("Model", "Unknown");
        }
    }
}





Console.WriteLine("*****************************************************************");
WMIQuery myWMIQuery = new WMIQuery();

var wmiProperties = myWMIQuery.ExecuteWMIQuery("SELECT * FROM Win32_BaseBoard");

foreach (var propertyDict in wmiProperties)
{
    foreach (var property in propertyDict)
    {
        Console.WriteLine($"{property.Key} = {property.Value}");
    }
    Console.WriteLine();
}