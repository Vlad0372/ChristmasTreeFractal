using System.Runtime.InteropServices;


namespace IFS_Fractals
{
    static class IFS_FractalsLib
    {
        private const string libName = "IFS_FractalsLib.DLL";

        [DllImport(libName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void srand(double seed);

        [DllImport(libName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern int rand();

        [DllImport(libName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void transform(ref double x, ref double y, int randVal);

        [DllImport(libName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern void calc_pixel(double x, ref int xe, double y, ref int ye);
    }
}
