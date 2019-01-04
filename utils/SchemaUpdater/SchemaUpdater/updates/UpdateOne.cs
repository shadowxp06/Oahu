using System.Text;
using SchemaUpdater.baseClasses;
using SchemaUpdater.utils;
using System;

namespace SchemaUpdater.updates
{
    class UpdateOne : UpdateFileBase
    {
        public UpdateOne(Updater upd) : base(upd)
        {
            _version = 1;
            _fileName = "UpdateOne.sql";
        }

        public void runOne()
        {
            if (_update.apiVersion <= _version)
            {
                readFile(_fileName);
                _update.executeNonQuery(_sb.ToString());

                if (_update.recordCount == 0)
                {
                    _errSb = new StringBuilder();
                    _errSb.AppendFormat("File {0} failed.", _fileName);
                    LogUtils.writeLog(enums.BaseEnums.LogLevel.Error, _errSb.ToString());
                }

                if (_update.doesTableExist("DatabaseInfo") == false)
                {
                    readFile("UpdateOne_createDatabaseInfo.sql");
                    _update.executeNonQuery(_sb.ToString());
                    if (_update.recordCount == 0)
                    {
                        _errSb = new StringBuilder();
                        _errSb.AppendFormat("File {0} failed.", _fileName);
                        LogUtils.writeLog(enums.BaseEnums.LogLevel.Error, _errSb.ToString());
                    }
                }

                if (_update.doesColumnExist("lastUpdate", "DatabaseInfo") == false)
                {
                    _sb = new StringBuilder();
                    _sb.AppendFormat("ALTER TABLE \"DatabaseInfo\" ADD COLUMN \"lastUpdate\" TIMESTAMP");
                    _update.executeNonQuery(_sb.ToString());
                    if (_update.recordCount == 0)
                    {
                        _errSb = new StringBuilder();
                        _errSb.Append("DatabaseInfo lastUpdate failed");
                        LogUtils.writeLog(enums.BaseEnums.LogLevel.Error, _errSb.ToString());
                    }
                }

                if (_update.doesTableExist("DatabaseInfo") == false)
                {
                    _update.executeQuery("SELECT * from \"DatabaseInfo\";");
                    if (_update.recordCount == 0)
                    {
                        _sb = new StringBuilder();
                        _sb.Append("INSERT INTO \"DatabaseInfo\" (\"dbversion\",\"uiversion\",\"apiversion\",\"lastUpdate\") ");
                        _sb.AppendFormat(" VALUES('1','1','1','{0}');", DateTime.Now);
                        _update.executeNonQuery(_sb.ToString());
                        if (_update.recordCount == 0)
                        {
                            _errSb = new StringBuilder();
                            _errSb.Append("DatabaseInfo Initial Insert Failed.");
                            LogUtils.writeLog(enums.BaseEnums.LogLevel.Error, _errSb.ToString());
                        }
                    }
                }       
            }
        }
    }
}
