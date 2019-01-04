using System;
using System.Text;
using Npgsql;
using SchemaUpdater.utils;
using SchemaUpdater.enums;
using System.Data;
namespace SchemaUpdater.baseClasses
{
    public class PostgresSQL
    {
        protected StringBuilder _sb;
        private NpgsqlConnection _conn;
        private Int64 _recordCount = 0;

        public string host
        {
            get;
            set;
        }

        public string user
        {
            get;
            set;
        }

        public string pass
        {
            get;
            set;
        }

        public string db
        {

            get;
            set;
        }

        public Int64 port
        {
            get;
            set;
        }

        public Int64 recordCount
        {
            get
            {
                return _recordCount;
            }
        }
     
        public PostgresSQL()
        {
            _sb = new StringBuilder();
            port = 5432;
        }

        protected void open()
        {
            _sb = new StringBuilder();
            _sb.AppendFormat("Host={0};Username={1};Password={2};Database={3}", host, user, pass, db);

            _conn = new NpgsqlConnection(_sb.ToString());
            try
            {
                _conn.Open();
            }catch(Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
        }

        protected void close()
        {
            try
            {
                if (_conn != null)
                {
                    _conn.Close();
                }
            }catch(Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
        }

        public void executeNonQuery(string query)
        {
            try
            {
                open();
                NpgsqlCommand cmd = new NpgsqlCommand(query, _conn);
                _recordCount = cmd.ExecuteNonQuery();
                close();
            }catch(Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
        }

        public DataTable executeQuery(string query)
        {
            DataTable dt = new DataTable();

            try
            {
                open();

                NpgsqlCommand cmd = new NpgsqlCommand(query, _conn);
                NpgsqlDataReader dr = cmd.ExecuteReader();

                dt.Load(dr);
                
                if (dt != null && dt.Rows.Count > 0)
                {
                    _recordCount = dt.Rows.Count;
                }

                close();
            }catch(Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }

            return dt;
        }

        public bool doesTableExist(string table)
        {
            bool exists = true;
            try
            {
                open();

                _sb = new StringBuilder();
                _sb.AppendFormat("SELECT Count(*) from information_schema.tables where table_name='{0}';", table);

                NpgsqlCommand cmd = new NpgsqlCommand(_sb.ToString(), _conn);

                Int64 count = (Int64)cmd.ExecuteScalar();

                exists = (count > 0);
                close();
            } catch(Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
            return exists;
        }

       public bool doesProcExist(string proc)
       {
            bool exists = true;
            try
            {
                open();

                _sb = new StringBuilder();
                _sb.Append("SELECT Exists(");
                _sb.Append("SELECT * from pg_catalog.pg_proc JOIN pg_namespace ON pg_catalog.pg_proc.pronamespace = pg_namespace.oid ");
                _sb.AppendFormat("WHERE proname = '{0}' and pg_namespace.nspname = 'public')", proc);

                NpgsqlCommand cmd = new NpgsqlCommand(_sb.ToString(), _conn);

                exists = (bool)cmd.ExecuteScalar();
                close();
            }
            catch (Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
            return exists;
        }

       public bool doesColumnExist(string col, string table)
        {
            bool exists = true;
            try
            {
                open();

                _sb = new StringBuilder();
                _sb.AppendFormat("SELECT Count(*) from information_schema.tables where table_name='{0}' and column_name='{1}';", table, col);

                NpgsqlCommand cmd = new NpgsqlCommand(_sb.ToString(), _conn);

                Int64 count = (Int64)cmd.ExecuteScalar();

                exists = (count > 0);
                close();
            }
            catch (Exception e)
            {
                LogUtils.writeLog(BaseEnums.LogLevel.Error, e.Message);
            }
            return exists;
        }

    }
}
