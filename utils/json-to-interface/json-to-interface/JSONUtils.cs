using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using System.IO;

namespace json_to_interface
{
    class JSONUtils
    {
        public static JObject getJObject(string fileLocation)
        {
            return JObject.Parse(File.ReadAllText(fileLocation));
        }
    }
}
