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
using Emgu.CV.Structure;
using System.Windows.Forms;
using System.Drawing;
using Emgu.CV.Util;
using Emgu.CV.CvEnum;
using System.Collections.Generic;

namespace BioSpace.Views
{
    public class CameraView : PictureBox
    {
        private readonly VideoCapture capture;
        private readonly Mat captureFrame;

        private const int ContourThreshold = 80;        //  Contour detection sensitivity of the script
        private const int SizeThreshold = 100;          //  Contour size threshold
        private const int MovementMargin = 40;          //  Max difference in coordinates
        private const int SegmentSize = 5;
        private const int SegmentThreshold = SegmentSize * SegmentSize / 3;
        private readonly Dictionary<Point, int> freqSegments = new Dictionary<Point, int>();
        private ulong frames;

        public CameraView(int idx)
        {
            captureFrame = new Mat();
            capture = new VideoCapture(idx);
            capture.ImageGrabbed += ImageGrabbed;
        }

        public void Start()
        {
            capture.Start();
            Size = new Size(capture.Width * 2 + 1, capture.Height + 1);
        }

        private void ImageGrabbed(object sender, EventArgs e)
        {
            if (capture.Ptr == IntPtr.Zero)
                return;

            Bitmap frame = new Bitmap(capture.Width, capture.Height);
            Graphics graphics = Graphics.FromImage(frame);

            capture.Retrieve(captureFrame);
            graphics.DrawImage(captureFrame.Bitmap, Point.Empty);

            GetContour(graphics);

            Image = frame;
        }

        private void GetContour(Graphics graphics)
        {
            // Convert the image into gray scale.
            var image = captureFrame.ToImage<Gray, byte>();

            // Invert black and white colors.
            image = image.Not();

            // Apply a threshold to convert black into white.
            image = image.ThresholdBinary(new Gray(ContourThreshold), new Gray(byte.MaxValue));
            //graphics.DrawImage(image.Bitmap, 0, 0);
            var imageData = (byte[,,])image.Data.Clone();

            VectorOfVectorOfPoint contoursDetected = new VectorOfVectorOfPoint();
            CvInvoke.FindContours(image, contoursDetected, null, RetrType.List,  ChainApproxMethod.ChainApproxSimple);
            for (int i = 0; i < contoursDetected.Size; i++) {
                if (CvInvoke.ContourArea(contoursDetected[i]) > 20)
                    CvInvoke.DrawContours(image, contoursDetected, i, new MCvScalar(255, 0, 0));
            }
            graphics.DrawImage(image.Bitmap, 0, 0);

            // Analyze image
            for (int x = 1; x < captureFrame.Width; x += SegmentSize) {
                for (int y = 1; y < captureFrame.Height; y += SegmentSize) {

                    int segmentBrightness = 0;
                    for (int i = 0; i < SegmentSize && x + i < captureFrame.Width; i++)
                        for (int j = 0; j < SegmentSize && y + j < captureFrame.Height; j++)
                            if (imageData[y + j, x + i, 0] < 127)
                                segmentBrightness++;

                    if (segmentBrightness > SegmentThreshold) {
                        var point = new Point(x, y);

                        if (!freqSegments.ContainsKey(point))
                            freqSegments.Add(point, 0);
                        else
                            freqSegments[point]++;

                        if (freqSegments[point] < frames * 0.2)
                            graphics.DrawRectangle(Pens.Blue, x, y, 12, 12);
                        
                    }
                }
            }

            frames++;
        }
    }
}

