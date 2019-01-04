using System.Text;
using System;
using SchemaUpdater.utils;
using System.IO;
namespace SchemaUpdater.baseClasses
{
    public class UpdateFileBase
    {
        protected StringBuilder _sb;
        protected StringBuilder _errSb;
        protected Updater _update;
        protected Int64 _version;

        protected string _fileName
        {
            get; set;
        }

        public UpdateFileBase(Updater upd)
        {
            _sb = new StringBuilder();
            _errSb = new StringBuilder();
            _update = upd;
        }

        protected void readFile(string file)
        {
            try
            {
                _sb = new StringBuilder();
                // string text = System.IO.File.ReadAllText(Directory.GetCurrentDirectory() + "\\sqlfiles\\UpdateOne.sql");
                string text = File.ReadAllText(Directory.GetCurrentDirectory() + "\\sqlFiles\\" + file);
                _sb.AppendLine(text);            
            }
            catch (Exception e)
            {
                LogUtils.writeLog(enums.BaseEnums.LogLevel.Error, e.Message);
            }
        }
    }
}
