//
//  MainWindow.cs
//
//  Author:
//       Benito Palacios Sánchez (aka pleonex) <benito356@gmail.com>
//
//  Copyright (c) 2016 Benito Palacios Sánchez
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
using System;
using System.Windows.Forms;
using System.Drawing;

namespace BioSpace.Views
{
    public class MainWindow : Form
    {
        private CameraView cameraView;

        public MainWindow()
        {
            CreateComponents();
        }

        private void CreateComponents()
        {
            SuspendLayout();

            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            Width  = 800;
            Height = 600;
            MinimumSize = new Size(800, 600);
            MaximumSize = new Size(800, 600);
            Text = "BioSpace";

            var button = new Button();
            button.Text = "Start";
            button.Location = new Point(0, 0);
            button.Click += (sender, e) => cameraView.Start();
            Controls.Add(button);

            cameraView = new CameraView(1);
            cameraView.Location = new Point(0, 30);
            cameraView.BackColor = Color.Black;
            Controls.Add(cameraView);
        }
    }
}

