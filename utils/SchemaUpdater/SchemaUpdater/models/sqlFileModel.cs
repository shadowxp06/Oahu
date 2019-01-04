using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SchemaUpdater.models
{
    public class sqlFileModel
    {
        public string fileName
        {
            get; set;
        }

        public Int64 minVersion
        {
            get; set;
        }
    }
}
