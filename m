From: Piet/Pete Delaney <piet@sgi.com>
Date: Fri, 22 Mar 2002 05:18:58 +0000
Subject: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and problems with LoadModule: "scanpci" wh
Message-Id: <marc-linux-ia64-105590701905328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905319@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905319@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 21, 2002 at 03:42:55PM -0800, Piet/Pete Delaney wrote:
> On Fri, Mar 22, 2002 at 08:30:54AM +1100, Keith Owens wrote:
.
.
.
This RedHat ia64 2.7 X11R6 problem occurs on:

		ia64 patched 2.4.18 Kernels 
but not on
		ia64 patched 2.4.17 kernels.

The kernel .config files for both kernels appear to be the same.

I just noticed that this RedHat 7.2 ia64 release is using a prerelease of XFree86 
and they suggest installing the current code from http://www.XFree86.Org/cvs:
...................................................................................
This is a pre-release version of XFree86, and is not supported in any
way.  Bugs may be reported to XFree86@XFree86.Org and patches submitted
to fixes@XFree86.Org.  Before reporting bugs in pre-release versions,
please check the latest version in the XFree86 CVS repository
(http://www.XFree86.Org/cvs)
...................................................................................

I'm checking out "." from CVSROOT=anoncvs@anoncvs.xfree86.org:/cvs and will give that
a shot tomarrow. For now 2.4.17 is fine.

-piet

> 
> ==============================================
> 				/var/log/XFree86.0.log
> ==============================================
> XFree86 Version 4.1.0.1 (Red Hat Linux release: 4.1.0-8) / X Window System
> (protocol Version 11, revision 0, vendor release 6510)
> Release Date: xx August 2001
>         If the server is older than 6-12 months, or if your card is
>         newer than the above date, look for a newer version before
>         reporting problems.  (See http://www.XFree86.Org/FAQ)
> Build Operating System: Linux 2.4.9-7.2smp ia64 [ELF]
> Build Host: boris.devel.redhat.com
> 
> Module Loader present
> (=) Log file: "/var/log/XFree86.0.log", Time: Sun Mar 31 13:57:41 2002
> (=) Using config file: "/etc/X11/XF86Config-4"
> Markers: (--) probed, (**) from config file, (=) default setting,
>          (++) from command line, (!!) notice, (II) informational,
>          (WW) warning, (EE) error, (NI) not implemented, (??) unknown.
> (=) ServerLayout "Anaconda Configured"
> (**) |-->Screen "Screen0" (0)
> (**) |   |-->Monitor "Monitor0"
> (**) |   |-->Device "ATI Rage 128"
> (**) |-->Input Device "Mouse0"
> (**) |-->Input Device "Keyboard0"
> (**) Option "XkbRules" "xfree86"
> (**) XKB: rules: "xfree86"
> (**) Option "XkbModel" "pc105"
> (**) XKB: model: "pc105"
> (**) Option "XkbLayout" "us"
> (**) XKB: layout: "us"
> (=) Keyboard: CustomKeycode disabled
> (**) FontPath set to "unix/:7100"
> (**) RgbPath set to "/usr/X11R6/lib/X11/rgb"
> (=) ModulePath set to "/usr/X11R6/lib/modules"
> (--) using VT number 7
> 
> (WW) Cannot open APM
> (II) Module ABI versions:
>         XFree86 ANSI C Emulation: 0.1
>         XFree86 Video Driver: 0.4
>         XFree86 XInput driver : 0.2
>         XFree86 Server Extension : 0.1
>         XFree86 Font Renderer : 0.2
> (II) Loader running on linux
> (II) LoadModule: "bitmap"
> (II) Loading /usr/X11R6/lib/modules/fonts/libbitmap.a
> (II) Module bitmap: vendor="The XFree86 Project"
>         compiled for 4.1.0.1, module version = 1.0.0
>         Module class: XFree86 Font Renderer
>         ABI class: XFree86 Font Renderer, version 0.2
> (II) Loading font Bitmap
> (II) LoadModule: "pcidata"
> (II) Loading /usr/X11R6/lib/modules/libpcidata.a
> (II) Module pcidata: vendor="The XFree86 Project"
>         compiled for 4.1.0.1, module version = 0.1.0
>         ABI class: XFree86 Video Driver, version 0.4
> (II) PCI: PCI scan (all values are in hex)
> (II) PCI: 00:00:0: chip 8086,123d card 0000,0000 rev 01 class 08,00,20 hdr 00
> (II) PCI: 00:01:0: chip 1002,5245 card 1002,0008 rev 00 class 03,00,00 hdr 00
> (II) PCI: 00:03:0: chip 8086,7600 card 0000,0000 rev 01 class 06,01,00 hdr 80
> (II) PCI: 00:03:1: chip 8086,7601 card 8086,4253 rev 01 class 01,01,80 hdr 00
> (II) PCI: 00:03:2: chip 8086,7602 card 8086,4253 rev 01 class 0c,03,00 hdr 00
> (II) PCI: 00:03:3: chip 8086,7603 card 8086,4253 rev 01 class 0c,05,00 hdr 00
> .
> .
> .
> (II) PCI: 04:15:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
> (II) PCI: 04:16:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
> (II) PCI: 04:17:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr 80
> (II) PCI: End of PCI scan
> (II) LoadModule: "scanpci"
> (II) Loading /usr/X11R6/lib/modules/libscanpci.a
> (II) Module scanpci: vendor="The XFree86 Project"
>         compiled for 4.1.0.1, module version = 0.1.0
>         ABI class: XFree86 Video Driver, version 0.4
> 
> Fatal server error:
> Caught signal 11.  Server aborting
> 
> 
> When reporting a problem related to a server crash, please send
> the full server output, not just the last messages.
> This can be found in the log file "/var/log/XFree86.0.log".
> Please report problems to xfree86@xfree86.org.
> ---------------------------------------------------------------------------
> I wonder if the error "(WW) Cannot open APM" is involved. I don't see
> a APM module in the kernel.
> 
> I searched RedHat's  Linux Support Knowledgebase but didn't find anything.
>
===================================================

