using System.Text;
using System;
namespace SchemaUpdater.baseClasses
{
    public class UpdateFileBase
    {
        protected StringBuilder _sb;
        protected Updater _update;
        protected Int64 _version;

        public UpdateFileBase(Updater upd)
        {
            _sb = new StringBuilder();
            _update = upd;
        }

        public void readFile(string file)
        {

        }
    }
}
