using System;
using System.Data;
using SchemaUpdater.updates;
using SchemaUpdater.utils;
namespace SchemaUpdater.baseClasses
{
    public class Updater : PostgresSQL
    {
        private Int64 _dbVersion;
        private double _apiVersion;
        private double _uiVersion;

        public Int64 dbVersion
        {
            get
            {
                return _dbVersion;
            }
        }

        public double apiVersion
        {
            get
            {
                return _apiVersion;
            }
        }

        public double uiVersion
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
                _apiVersion = (double)dr["apiversion"];
                _uiVersion = (double)dr["uiversion"];
            }
        }

        private void fixPermissions()
        {
            if (user != "postgres")
            {
                _sb = new System.Text.StringBuilder();
                _sb.AppendFormat("GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public to \"{0}\"", user);
                executeNonQuery(_sb.ToString());
            }

            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public to \"{0}\"", "oahu_user");
            executeNonQuery(_sb.ToString());
        }

        private void updateLastUpdate()
        {
            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("UPDATE \"DatabaseInfo\" set \"lastUpdate\" = '{0}' ", DateTime.Now);
            executeNonQuery(_sb.ToString());
        }

        private void updateDBVersion()
        {
            if (doDBVersionUpdate)
            {
                setDBVersion(dbVersion + 1);
            }
        }

        public void runUpdates()
        {
            UpdateOne updOne = new UpdateOne(this);
            updOne.runOne();
            updOne.runTwo();

            updateLastUpdate();
            updateDBVersion();
            fixPermissions();
        }

        public void fixAWSPermissions()
        {
            // Template holder for fixing AWS Permissions.
        }

        public void setDBVersion(Int64 ver)
        {
            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("UPDATE \"DatabaseInfo\" set \"dbversion\" = '{0}' ", ver);

            executeNonQuery(_sb.ToString());

            if (recordCount > 0)
            {
                _dbVersion = ver;
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Info, "DB Version has been set to " + dbVersion);
            }
            else
            {
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Fatal, "DB Version has NOT been updated.");
            }
        }

        public void setAPIVersion(Double ver)
        {
            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("UPDATE \"DatabaseInfo\" set \"apiversion\" = '{0}' ", ver);

            executeNonQuery(_sb.ToString());

            if (recordCount > 0)
            {
                _apiVersion = ver;
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Info, "API Version has been set to " + apiVersion);
            }
            else
            {
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Fatal, "API Version has NOT been updated.");
            }
        }

        public void setUIVersion(Double ver)
        {
            _sb = new System.Text.StringBuilder();
            _sb.AppendFormat("UPDATE \"DatabaseInfo\" set \"uiversion\" = '{0}' ", ver);

            executeNonQuery(_sb.ToString());

            if (recordCount > 0)
            {
                _uiVersion = ver;
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Info, "UI Version has been set to " + uiVersion);
            }
            else
            {
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Fatal, "UI Version has NOT been updated.");
            }
        }
    }
}
