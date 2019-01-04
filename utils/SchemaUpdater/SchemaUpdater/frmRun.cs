using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SchemaUpdater.baseClasses;

namespace SchemaUpdater
{
    public partial class frmRun : Form
    {
        private Updater _updater;
        public frmRun()
        {
            InitializeComponent();
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            Updater update = new Updater();
            update.host = txtHost.Text;
            update.db = txtDB.Text;
            update.user = txtUser.Text;
            update.pass = txtPass.Text;

            update.setDBVersion();
            MessageBox.Show("Update completed.");
        }

        private void frmRun_Load(object sender, EventArgs e)
        {
            txtDB.Text = "omsdiscussions";
            _updater = new Updater();
        }

        private void devTestCmd_Click(object sender, EventArgs e)
        {
            Updater update = new Updater();
            update.host = "127.0.0.1";
            update.db = "omsdiscussions";
            update.user = "oahu_user";
            update.pass = "password123";

            update.setDBVersion();
        }
    }
}
