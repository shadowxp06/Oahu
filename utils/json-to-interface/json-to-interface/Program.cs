using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using System.IO;

namespace json_to_interface
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0 || (args.Length > 0 && args.Length < 3))
            {
                Console.WriteLine("Arguments: <timezone> <orig json file> <output file>");
                Console.ReadLine();
            }

            if (args[0].ToLower().Equals("timezone"))
            {
                JObject o1 = JSONUtils.getJObject(args[1]);
                Dictionary<string, string> dictObj = o1.ToObject<Dictionary<string, string>>();
                StringBuilder sb = new StringBuilder("{ \"timezones\": [ ");
                foreach (KeyValuePair<string, string> entry in dictObj)
                {
                    sb.Append("{ ");
                    string[] sep = entry.Value.Split(' ');
                    string value = sep[0].Remove(sep[0].Length - 1).Remove(0, 1);
                    sb.AppendFormat(" \"zonename\": \"{0} ({1})\", \"value\":\"{1}\" ", entry.Key, value);
                    sb.Append(" },");
                }
                sb.Append(" ] }");

                File.WriteAllText(args[2], sb.ToString());
            }

            Console.Write("Completed");
        }


    }
}
