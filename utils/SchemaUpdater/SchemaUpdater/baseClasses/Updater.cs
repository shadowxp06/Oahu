using System;
using System.Data;
using SchemaUpdater.updates;
using SchemaUpdater.utils;
namespace SchemaUpdater.baseClasses
{
    public class Updater : PostgresSQL
    {
        private Int64 _dbVersion;
        private Int64 _apiVersion;
        private Int64 _uiVersion;

        public Int64 dbVersion
        {
            get
            {
                return _dbVersion;
            }
        }

        public Int64 apiVersion
        {
            get
            {
                return _apiVersion;
            }
        }

        public Int64 uiVersion
        {
            get
            {
                return _uiVersion;
            }
        }

        public bool doDBVersionUpdate
        {
            get; set;
        }

        public Updater()
        {
            _dbVersion = 0;
            _apiVersion = 0;
            _uiVersion = 0;
        }

        public void setDBVersion()
        {
            DataTable dt = executeQuery("SELECT * from \"DatabaseInfo\"");

            if (dt != null && dt.Rows.Count > 0)
            {
                DataRow dr = dt.Rows[0];
                _dbVersion = (Int32)dr["dbversion"];
                _apiVersion = (Int64)dr["apiversion"];
                _uiVersion = (Int64)dr["uiversion"];
            }
        }

        private void fixPermissions()
        {
            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public to \"{0}\"", user);
            executeNonQuery(_sb.ToString());
        }

        private void updateLastUpdate()
        {
            
        }

        private void updateDBVersion()
        {
            if (doDBVersionUpdate)
            {
                _sb = new System.Text.StringBuilder();
                _sb.AppendFormat("UPDATE \"DatabaseInfo\" set \"dbversion\" = '{0}' ", (dbVersion + 1));

                executeNonQuery(_sb.ToString());

                if (recordCount > 0)
                {
                    LogUtils.writeLog(enums.BaseEnums.LogLevel.Info, "DB Version has been updated successfully");
                } else
                {
                    LogUtils.writeLog(enums.BaseEnums.LogLevel.Fatal, "DB Version has NOT been updated.");
                }
            }
        }

        public void runUpdates()
        {
            UpdateOne updOne = new UpdateOne(this);
            updOne.runOne();

            updateLastUpdate();
            updateDBVersion();
            fixPermissions();
        }
    }
}
