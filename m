From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Sep 2002 20:47:45 +0000
Subject: RE: [Linux-ia64] running x86 mozilla with "skin" support etc.
Message-Id: <marc-linux-ia64-105590701906047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906046@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906046@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Sep 2002 12:58:07 -0700, "Wichmann, Mats D" <mats.d.wichmann@intel.com> said:

  Mats> I'm wrapping up pushing through the LSB specification for ia64,
  Mats> and making sure we've said the right things about x86 support.

Cool.

  Mats> What I'd really like to have is a serious "case study" or two 
  Mats> that I can use to prove that things are okay.

  Mats> Maybe I could use mozilla as one of them....

Yes, Mozilla probably isn't a bad test case.

Actually, I just realized that it's possible to get mozilla-1.0.1/x86
to run properly without needing the x86 version of /usr/bin/convert.
This simplifies things a lot.  The problem and the solution is below:

 Problem:

   Binary-only mozilla plug-ins sometimes are really just Netscape 4.x
   plugins.  Netscape 4.x was linked against libXt, so those plugins
   could use Xt-functionality without explicitly being linked against
   libXt.  The net effect is that those plugins won't work without
   pre-loading libXt.so.6.  I used to achieve that by adding the
   following line to "run-mozilla.sh":

     export LD_PRELOAD=/emul/ia32-linux/usr/X11R6/lib/libXt.so.6

   Of course, once you do that, you can't exec ia64 binaries anymore,
   because they'd try to load an x86 shared object.  For this reason,
   execing (the ia64 version of) /usr/bin/convert would fail.

 Solution:
   The problem can be solved in two ways: install x86 versions of all binaries
   that may be exec'd by an x86 application.  In the mozilla case, this
   included /usr/bin/convert.

   A better solution is to change the LD_PRELOAD line in "run-mozilla.sh" to:

     export LD_PRELOAD=/usr/X11R6/lib/libXt.so.6

   This way, x86 binaries will still preload the x86 version of the library,
   while ia64 binaries continue to be exec'utable (they'll preload the
   ia64 version of libXt.so.6, which normally doesn't hurt anything).

For completeness, I appended a list of files that I added to get the
x86-version of /usr/bin/convert to work.  These files are needed on
top of what the "ia32-libs" Debian package provides.

Note: The list below also includes bin/uname.  This isn't needed for
mozilla, but I installed it so that x86 apps that spawn "uname" will
get the expected answer for the machine architecture.

	--david

./usr/lib/libXaw.so.6.1
./usr/lib/libXaw.so.6
./usr/lib/libgmodule-1.2.so.0.0.10
./usr/lib/libgmodule-1.2.so.0
./usr/lib/libglib-1.2.so.0.0.10
./usr/lib/libglib-1.2.so.0
./usr/lib/gtk/themes/engines/libmetal.la
./usr/lib/gtk/themes/engines/libnotif.la
./usr/lib/gtk/themes/engines/libpixmap.la
./usr/lib/gtk/themes/engines/libpixmap.so
./usr/lib/gtk/themes/engines/libraleigh.la
./usr/lib/gtk/themes/engines/libredmond95.la
./usr/lib/libgdk_imlib.so.1.9.11
./usr/lib/libgdk_imlib.so.1
./usr/lib/libMagick.so.5.0.43
./usr/lib/libMagick.so.5
./usr/lib/liblcms.so.1.08
./usr/lib/liblcms.so.1
./usr/lib/libtiff.so.3.5.5
./usr/lib/libtiff.so.3
./usr/lib/libwmf-0.2.so.2
./usr/lib/libjpeg.so.62.0.0
./usr/lib/libjpeg.so.62
./usr/lib/libpng.so.2.1.0.12
./usr/lib/libpng.so.2
./usr/lib/libxml2.so.2
./usr/lib/gdk-imlib1/libimlib-bmp.so
./usr/lib/gdk-imlib1/libimlib-gif.so
./usr/lib/gdk-imlib1/libimlib-jpeg.so
./usr/lib/gdk-imlib1/libimlib-png.so
./usr/lib/gdk-imlib1/libimlib-ppm.so
./usr/lib/gdk-imlib1/libimlib-ps.so
./usr/lib/gdk-imlib1/libimlib-tiff.so
./usr/lib/gdk-imlib1/libimlib-xpm.so
./usr/X11R6/lib/libgtk-1.2.so.0.9.1
./usr/X11R6/lib/libgtk-1.2.so.0
./usr/X11R6/lib/libgdk-1.2.so.0.9.1
./usr/X11R6/lib/libgdk-1.2.so.0
./usr/X11R6/lib/libdps.so.1.0
./usr/X11R6/lib/libdpstk.so.1.0
./usr/X11R6/lib/libdpstk.so.1
./usr/X11R6/lib/libdps.so.1
./usr/X11R6/lib/libbz2.so.1.0
./bin/uname

