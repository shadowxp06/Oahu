using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
namespace SchemaUpdater.classes
{
    class PostgresSQL
    {
        private StringBuilder _sb;
        private NpgsqlConnection _conn;
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
     
        public PostgresSQL()
        {
            _sb = new StringBuilder();
        }

        public void open()
        {
            _sb = new StringBuilder();
            _sb.AppendFormat("Host={0};Username={1};Password={2};Database={3}", host, user, pass, db);

            _conn = new NpgsqlConnection(_sb.ToString());
            try
            {

            }catch(Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        public void close()
        {

        }
    }
}
