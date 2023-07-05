using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IFS_Fractals
{
    public partial class Form1 : Form
    {
        private double x;
        private double y;
        private int xe;
        private int ye;
        private double seed;
        private Graphics canvas;
        private Point[] points;
        private int numbOfPoints;
        public Form1()
        {
            InitializeComponent();

            x = 0.0;
            y = 0.0;
            xe = 0;
            ye = 0;

            numbOfPoints = 50000;
            points = new Point[numbOfPoints];

            canvas = panel1.CreateGraphics();

            seed = 0;// (int)(DateTime.Now - DateTime.UnixEpoch).TotalSeconds; //seconds since 1970
            IFS_FractalsLib.srand(seed);
        }

        private void DrawFractalBtn_Click(object sender, EventArgs e)
        {
            int randVal = 0;

            for (int i = 0; i < points.Length; i++)
            {
                randVal = IFS_FractalsLib.rand();

                IFS_FractalsLib.transform(ref x, ref y, randVal);
                IFS_FractalsLib.calc_pixel(x, ref xe, y, ref ye);
                points[i].X = xe;
                points[i].Y = ye;
            }

            Brush br1 = (Brush)Brushes.Black;

            for (int i = 0; i < points.Length; i++)
            {
                canvas.FillRectangle(br1, points[i].X, points[i].Y, 2, 2);
            }

            button1.Enabled = false;
            button2.Enabled = true;
        }

        private void ResetValsBtn_Click(object sender, EventArgs e)
        {
            x = 0.0;
            y = 0.0;
            xe = 0;
            ye = 0;

            canvas.Clear(Color.White);
            Array.Clear(points, 0, points.Length);

            seed = (int)(DateTime.Now - DateTime.UnixEpoch).TotalSeconds; //seconds since 1970
            IFS_FractalsLib.srand(seed);

            button2.Enabled = false;
            button1.Enabled = true;
        }
    }
}
