namespace SchemaUpdater
{
    partial class frmRun
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.txtUser = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.txtPass = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.txtDB = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.txtHost = new System.Windows.Forms.TextBox();
            this.btnOK = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.chkDoVerUpdate = new System.Windows.Forms.CheckBox();
            this.toolsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.changeDBVersionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.changeUIVersionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.changeAPIVersionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.fixAWSPermissionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuDevTest = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // txtUser
            // 
            this.txtUser.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtUser.Location = new System.Drawing.Point(119, 30);
            this.txtUser.Name = "txtUser";
            this.txtUser.Size = new System.Drawing.Size(214, 26);
            this.txtUser.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(17, 36);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(87, 20);
            this.label1.TabIndex = 1;
            this.label1.Text = "Username:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(17, 77);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(82, 20);
            this.label2.TabIndex = 3;
            this.label2.Text = "Password:";
            // 
            // txtPass
            // 
            this.txtPass.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtPass.Location = new System.Drawing.Point(119, 71);
            this.txtPass.Name = "txtPass";
            this.txtPass.PasswordChar = '*';
            this.txtPass.Size = new System.Drawing.Size(214, 26);
            this.txtPass.TabIndex = 2;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(17, 123);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(83, 20);
            this.label3.TabIndex = 5;
            this.label3.Text = "Database:";
            // 
            // txtDB
            // 
            this.txtDB.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtDB.Location = new System.Drawing.Point(119, 117);
            this.txtDB.Name = "txtDB";
            this.txtDB.Size = new System.Drawing.Size(214, 26);
            this.txtDB.TabIndex = 4;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(17, 162);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(47, 20);
            this.label4.TabIndex = 7;
            this.label4.Text = "Host:";
            // 
            // txtHost
            // 
            this.txtHost.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtHost.Location = new System.Drawing.Point(119, 159);
            this.txtHost.Name = "txtHost";
            this.txtHost.Size = new System.Drawing.Size(214, 26);
            this.txtHost.TabIndex = 6;
            // 
            // btnOK
            // 
            this.btnOK.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnOK.Location = new System.Drawing.Point(253, 204);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(80, 31);
            this.btnOK.TabIndex = 8;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.toolsToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(342, 24);
            this.menuStrip1.TabIndex = 9;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "&File";
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.exitToolStripMenuItem.Text = "&Exit";
            // 
            // chkDoVerUpdate
            // 
            this.chkDoVerUpdate.AutoSize = true;
            this.chkDoVerUpdate.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.chkDoVerUpdate.Location = new System.Drawing.Point(21, 211);
            this.chkDoVerUpdate.Name = "chkDoVerUpdate";
            this.chkDoVerUpdate.Size = new System.Drawing.Size(173, 24);
            this.chkDoVerUpdate.TabIndex = 10;
            this.chkDoVerUpdate.Text = "Do Version Update?";
            this.chkDoVerUpdate.UseVisualStyleBackColor = true;
            // 
            // toolsToolStripMenuItem
            // 
            this.toolsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuDevTest,
            this.changeDBVersionToolStripMenuItem,
            this.changeUIVersionToolStripMenuItem,
            this.changeAPIVersionToolStripMenuItem,
            this.fixAWSPermissionsToolStripMenuItem});
            this.toolsToolStripMenuItem.Name = "toolsToolStripMenuItem";
            this.toolsToolStripMenuItem.Size = new System.Drawing.Size(47, 20);
            this.toolsToolStripMenuItem.Text = "Tools";
            // 
            // changeDBVersionToolStripMenuItem
            // 
            this.changeDBVersionToolStripMenuItem.Name = "changeDBVersionToolStripMenuItem";
            this.changeDBVersionToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.changeDBVersionToolStripMenuItem.Text = "Change DB Version";
            this.changeDBVersionToolStripMenuItem.Click += new System.EventHandler(this.changeDBVersionToolStripMenuItem_Click);
            // 
            // changeUIVersionToolStripMenuItem
            // 
            this.changeUIVersionToolStripMenuItem.Name = "changeUIVersionToolStripMenuItem";
            this.changeUIVersionToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.changeUIVersionToolStripMenuItem.Text = "Change UI Version";
            this.changeUIVersionToolStripMenuItem.Click += new System.EventHandler(this.changeUIVersionToolStripMenuItem_Click);
            // 
            // changeAPIVersionToolStripMenuItem
            // 
            this.changeAPIVersionToolStripMenuItem.Name = "changeAPIVersionToolStripMenuItem";
            this.changeAPIVersionToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.changeAPIVersionToolStripMenuItem.Text = "Change API Version";
            this.changeAPIVersionToolStripMenuItem.Click += new System.EventHandler(this.changeAPIVersionToolStripMenuItem_Click);
            // 
            // fixAWSPermissionsToolStripMenuItem
            // 
            this.fixAWSPermissionsToolStripMenuItem.Name = "fixAWSPermissionsToolStripMenuItem";
            this.fixAWSPermissionsToolStripMenuItem.Size = new System.Drawing.Size(181, 22);
            this.fixAWSPermissionsToolStripMenuItem.Text = "Fix AWS Permissions";
            this.fixAWSPermissionsToolStripMenuItem.Click += new System.EventHandler(this.fixAWSPermissionsToolStripMenuItem_Click);
            // 
            // mnuDevTest
            // 
            this.mnuDevTest.Name = "mnuDevTest";
            this.mnuDevTest.Size = new System.Drawing.Size(181, 22);
            this.mnuDevTest.Text = "Dev Test";
            // 
            // frmRun
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(342, 249);
            this.Controls.Add(this.chkDoVerUpdate);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.txtHost);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.txtDB);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.txtPass);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtUser);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "frmRun";
            this.Text = "Oahu Schema Updater";
            this.Load += new System.EventHandler(this.frmRun_Load);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox txtUser;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtPass;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtDB;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox txtHost;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.CheckBox chkDoVerUpdate;
        private System.Windows.Forms.ToolStripMenuItem toolsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem changeDBVersionToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem changeUIVersionToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem changeAPIVersionToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem fixAWSPermissionsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem mnuDevTest;
    }
}

