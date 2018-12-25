using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SchemaUpdater.classes;

namespace SchemaUpdater
{
    public partial class frmRun : Form
    {
        private PostgresSQL _postgres;
        public frmRun()
        {
            InitializeComponent();
        }

        private void btnOK_Click(object sender, EventArgs e)
        {

        }

        private void frmRun_Load(object sender, EventArgs e)
        {
            txtDB.Text = "omsdiscussions";
            _postgres = new PostgresSQL();
        }
    }
}
