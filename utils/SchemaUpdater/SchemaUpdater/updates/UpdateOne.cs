using System.Text;
using SchemaUpdater.baseClasses;
using SchemaUpdater.utils;

namespace SchemaUpdater.updates
{
    class UpdateOne : UpdateFileBase
    {
        public UpdateOne(Updater upd) : base(upd)
        {
            _sb = new StringBuilder();
            _version = 1;
        }

        public void runOne()
        {
            if (_update.apiVersion <= _version)
            {
                if (_update.doesColumnExist("lastUpdate", "DatabaseInfo"))
                {
                    _sb.AppendFormat("ALTER TABLE \"DatabaseInfo\" ADD COLUMN \"lastUpdate\" TIMESTAMP");
                    _update.executeNonQuery(_sb.ToString());
                    if (_update.recordCount > 0)
                    {
                        LogUtils.writeLog(enums.BaseEnums.LogLevel.Info, "Update Successful - Column Added - Database Info");
                    } else
                    {
                        LogUtils.writeLog(enums.BaseEnums.LogLevel.Fatal, "Update unsuccessful - Column not added - Database Info");
                    }
                }
            }
        }
    }
}
