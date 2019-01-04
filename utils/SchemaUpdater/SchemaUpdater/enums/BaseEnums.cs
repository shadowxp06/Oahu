using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;

namespace SchemaUpdater.enums
{
    class BaseEnums
    {
        public enum LogLevel
        {
            [Description("Error")]
            Error = 0,
            [Description("Warning")]
            Warn = 1,
            [Description("Info")]
            Info = 2,
            [Description("Fatal")]
            Fatal = 3
        }

    }
}
