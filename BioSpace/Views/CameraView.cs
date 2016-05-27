//
//  CameraView.cs
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
using Emgu.CV;
using Emgu.CV.UI;

namespace BioSpace.Views
{
    public class CameraView : ImageBox
    {
        private readonly VideoCapture capture;
        private readonly Mat frame;

        public CameraView(int idx)
        {
            frame = new Mat();
            capture = new VideoCapture(idx);
            capture.ImageGrabbed += ImageGrabbed;
        }

        public void Start()
        {
            capture.Start();
            Size = new System.Drawing.Size(capture.Width + 1, capture.Height + 1);
        }

        private void ImageGrabbed(object sender, EventArgs e)
        {
            if (capture.Ptr == IntPtr.Zero)
                return;
            
            capture.Retrieve(frame);
            Image = frame;
        }
    }
}

