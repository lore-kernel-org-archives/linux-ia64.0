From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Sep 2002 20:57:55 +0000
Subject: RE: [Linux-ia64] running x86 mozilla with "skin" support etc.
Message-Id: <marc-linux-ia64-105590701906048@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906046@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906046@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Sep 2002 13:47:45 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  > For completeness, I appended a list of files that I added to
  > get the x86-version of /usr/bin/convert to work.  These files
  > are needed on top of what the "ia32-libs" Debian package
  > provides.

Oops, I forgot to mention that this list of files is of course
relative to /emul/ia32-linux/

	--david

  > ./usr/lib/libXaw.so.6.1
  > ./usr/lib/libXaw.so.6
  > ./usr/lib/libgmodule-1.2.so.0.0.10
  > ./usr/lib/libgmodule-1.2.so.0
  > ./usr/lib/libglib-1.2.so.0.0.10
  > ./usr/lib/libglib-1.2.so.0
  > ./usr/lib/gtk/themes/engines/libmetal.la
  > ./usr/lib/gtk/themes/engines/libnotif.la
  > ./usr/lib/gtk/themes/engines/libpixmap.la
  > ./usr/lib/gtk/themes/engines/libpixmap.so
  > ./usr/lib/gtk/themes/engines/libraleigh.la
  > ./usr/lib/gtk/themes/engines/libredmond95.la
  > ./usr/lib/libgdk_imlib.so.1.9.11
  > ./usr/lib/libgdk_imlib.so.1
  > ./usr/lib/libMagick.so.5.0.43
  > ./usr/lib/libMagick.so.5
  > ./usr/lib/liblcms.so.1.08
  > ./usr/lib/liblcms.so.1
  > ./usr/lib/libtiff.so.3.5.5
  > ./usr/lib/libtiff.so.3
  > ./usr/lib/libwmf-0.2.so.2
  > ./usr/lib/libjpeg.so.62.0.0
  > ./usr/lib/libjpeg.so.62
  > ./usr/lib/libpng.so.2.1.0.12
  > ./usr/lib/libpng.so.2
  > ./usr/lib/libxml2.so.2
  > ./usr/lib/gdk-imlib1/libimlib-bmp.so
  > ./usr/lib/gdk-imlib1/libimlib-gif.so
  > ./usr/lib/gdk-imlib1/libimlib-jpeg.so
  > ./usr/lib/gdk-imlib1/libimlib-png.so
  > ./usr/lib/gdk-imlib1/libimlib-ppm.so
  > ./usr/lib/gdk-imlib1/libimlib-ps.so
  > ./usr/lib/gdk-imlib1/libimlib-tiff.so
  > ./usr/lib/gdk-imlib1/libimlib-xpm.so
  > ./usr/X11R6/lib/libgtk-1.2.so.0.9.1
  > ./usr/X11R6/lib/libgtk-1.2.so.0
  > ./usr/X11R6/lib/libgdk-1.2.so.0.9.1
  > ./usr/X11R6/lib/libgdk-1.2.so.0
  > ./usr/X11R6/lib/libdps.so.1.0
  > ./usr/X11R6/lib/libdpstk.so.1.0
  > ./usr/X11R6/lib/libdpstk.so.1
  > ./usr/X11R6/lib/libdps.so.1
  > ./usr/X11R6/lib/libbz2.so.1.0
  > ./bin/uname

