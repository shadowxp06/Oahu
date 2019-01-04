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
using System.IO;
using SchemaUpdater.utils;

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
            _updater.host = txtHost.Text;
            _updater.db = txtDB.Text;
            _updater.user = txtUser.Text;
            _updater.pass = txtPass.Text;

            _updater.setDBVersion();
            _updater.runUpdates();
            MessageBox.Show("Update completed.  If you have run this on AWS, please use the Fix Permissions under the AWS Menu.");
        }

        private void frmRun_Load(object sender, EventArgs e)
        {
            txtDB.Text = "omsdiscussions";
            _updater = new Updater();
            mnuDevTest.Visible = false;
        }

        private void fixAWSPermissionsToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void changeDBVersionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (_updater.dbVersion == 0)
            {
                _updater.host = txtHost.Text;
                _updater.db = txtDB.Text;
                _updater.user = txtUser.Text;
                _updater.pass = txtPass.Text;

                _updater.setDBVersion();
            }

            if (_updater.dbVersion > 0)
            {
                string input = Microsoft.VisualBasic.Interaction.InputBox("Enter a new version", "DB Version");
                if (!input.Equals(""))
                {
                    _updater.setDBVersion(Convert.ToInt32(input));
                    MessageBox.Show("DB Version Updated");
                }
            }
        }

        private void changeUIVersionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (_updater.dbVersion == 0)
            {
                _updater.host = txtHost.Text;
                _updater.db = txtDB.Text;
                _updater.user = txtUser.Text;
                _updater.pass = txtPass.Text;

                _updater.setDBVersion();
            }

            if (_updater.dbVersion > 0)
            {
                string input = Microsoft.VisualBasic.Interaction.InputBox("Enter a new version", "UI Version");
                if (!input.Equals(""))
                {
                    _updater.setUIVersion(Convert.ToDouble(input));
                    MessageBox.Show("UI Version Updated");
                }
            }
        }

        private void changeAPIVersionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (_updater.dbVersion == 0)
            {
                _updater.host = txtHost.Text;
                _updater.db = txtDB.Text;
                _updater.user = txtUser.Text;
                _updater.pass = txtPass.Text;

                _updater.setDBVersion();
            }

            if (_updater.dbVersion > 0)
            {
                string input = Microsoft.VisualBasic.Interaction.InputBox("Enter a new version", "API Version");
                if (!input.Equals(""))
                {
                    _updater.setAPIVersion(Convert.ToDouble(input));
                    MessageBox.Show("API Version Updated");
                }
            }
        }
    }
}
