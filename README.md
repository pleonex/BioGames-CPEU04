This is a C# implementation to recognize bacterias for biogames.
Original idea from [BioticGamesAtWaag](https://github.com/bioticgamesatwaag/campus_party).

# Compile
To compile in follow these instructions:

1. Install mono.
2. Compile Emgu.CV following this [instruction](http://www.emgu.com/wiki/index.php/Download_And_Installation) (skip the process to clone).
3. Compile the project from monodevelop or via command `xbuild BioSpace.sln`.

**Note**: The video device to read is specified by its index in line 54 of *Views/MainWindow.cs*.

**Note**: If you ran into the following issue when trying to compile Emgu.CV:
`/lib/libbz2.so.1: error adding symbols:`
Run the following command on the root Emgu.CV repository:
`sed -i 's#/lib/libbz2.so.1#/lib64/libbz2.so.1#g' CMakeCache.txt`

**Note**: If you ran into the following issue when trying to compile Emgu.CV:
`Unable to locate tools.jar. Expected to find it in /opt/jre1.8.0_60/lib/tools.jar`
Make sure you have defined the environment variable `JAVA_HOME` and it's pointing to your JDK.
