using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SchemaUpdater.enums;
namespace SchemaUpdater.utils
{
    class LogUtils
    {
        private static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        public static void writeLog(BaseEnums.LogLevel logLevel, string message)
        {
            switch(logLevel)
            {
                case BaseEnums.LogLevel.Error:
                    log.Error(message);
                    break;
                case BaseEnums.LogLevel.Info:
                    log.Info(message);
                    break;
                case BaseEnums.LogLevel.Warn:
                    log.Warn(message);
                    break;
                default:
                    log.Debug(message);
                    break;
            }
        }
    }
}
