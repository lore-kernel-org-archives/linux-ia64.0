From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Mar 2002 16:59:43 +0000
Subject: RE: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and
Message-Id: <marc-linux-ia64-105590701905329@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905319@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905319@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Starting with 2.4.18 the IA64 kernel doesn't make the stack executable
by default ... this upsets XFree86.  Here is a clip from David Mosberger's
2.4.18 announcment that tells you how to fix this:

IMPORTANT:

Starting with this patch, the stack and and pages are no longer
executable by default!  This will hopefully increase resilience
against buffer-overflow attacks (though it's no guarantee) and also
has the benefit that it lets us drop the lazy-execute bit support.
The latter has two implications: we can use the standard page-fault
handler again and applications that generate code on the fly are no
longer penalized with extra page faults.  On the downside, there is
currently a known bug in the XFree86 server where it incorrectly
assumes that data pages are executable by default.  For this reason,
you'll need to use the chatr utility which I posted earlier to mark
the XFree86 server as having executable data.  A command of the form:

	$ chatr --executable-stack /usr/X11R6/bin/XFree86

should do the trick (source code for chatr is appended).  You must do
this as otherwise XFree86 will die while trying to load some of its
modules (it normally dies in the scanpci module).

<-- chatr.c -->
#include <elf.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/types.h>

#ifndef EF_IA_64_LINUX_EXECUTABLE_STACK
# define EF_IA_64_LINUX_EXECUTABLE_STACK	0x1
#endif

static struct option long_options[] = {
  {"executable-stack", 0, 0, 'E'},
  {"help", 0, 0, 'h'},
  {"no-executable-stack", 0, 0, 'e'},
};

static const char *prog_name;

static void
usage (FILE *fp)
{
  fprintf (fp, "Usage: %s [-eEh] files...\n"
	   "\t-e: mark stack and data of image as not executable\n"
	   "\t-E: mark stack and data of image as executable\n"
	   "\t-h: print this help message\n", prog_name);
}

static void
update_file (const char *filename, int executable_stack)
{
  Elf64_Ehdr ehdr;
  ssize_t ret;
  int fd;

  fd = open (filename, executable_stack ? O_RDWR : O_RDONLY);
  if (fd < 0)
    {
      perror (filename);
      exit (-1);
    }

  ret = read (fd, &ehdr, sizeof (ehdr));
  if (ret != sizeof (ehdr))
    {
      if (ret < 0)
	perror (filename);
      else
	fprintf (stderr, "%s: short read\n", filename);
      exit (-1);
    }

  if (executable_stack = 0)
    {
      printf ("%s:\n\tstack and data executable: %s\n", filename,
	      (ehdr.e_flags & EF_IA_64_LINUX_EXECUTABLE_STACK) ? "yes" :
"no");
      return;
    }

  if (executable_stack = 1)
    ehdr.e_flags |= EF_IA_64_LINUX_EXECUTABLE_STACK;
  else
    ehdr.e_flags &= ~EF_IA_64_LINUX_EXECUTABLE_STACK;

  if (lseek (fd, 0, SEEK_SET) < 0)
    {
      perror ("lseek");
      exit (-1);
    }

  ret = write (fd, &ehdr, sizeof (ehdr));
  if (ret != sizeof (ehdr))
    {
      perror ("write");
      exit (-1);
    }
}

int
main (int argc, char **argv)
{
  int ch, executable_stack = 0;
  extern int optind;

  prog_name = argv[0];

  if (argc < 2)
    {
      usage (stderr);
      exit (-1);
    }

  while (1)
    {
      ch = getopt_long (argc, argv, "eEh", long_options, NULL);
      if (ch = -1)
	break;

      switch (ch)
	{
	case 'e': executable_stack = -1; break;
	case 'E': executable_stack =  1; break;
	case 'h': usage (stdout); exit (0);
	}
    }

  while (optind < argc)
    update_file (argv[optind++], executable_stack);

  return 0;
}
<--end chatr.c-->

-----Original Message-----
From: Piet/Pete Delaney [mailto:piet@sgi.com]
Sent: Thursday, March 21, 2002 9:19 PM
To: Keith Owens; xfree86@xfree86.org
Cc: Piet Delaney; linux-ia64@linuxia64.org
Subject: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and
problems with LoadModule: "scanpci" what starting XFree86.


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

I just noticed that this RedHat 7.2 ia64 release is using a prerelease of
XFree86 
and they suggest installing the current code from
http://www.XFree86.Org/cvs:
............................................................................
.......
This is a pre-release version of XFree86, and is not supported in any
way.  Bugs may be reported to XFree86@XFree86.Org and patches submitted
to fixes@XFree86.Org.  Before reporting bugs in pre-release versions,
please check the latest version in the XFree86 CVS repository
(http://www.XFree86.Org/cvs)
............................................................................
.......

I'm checking out "." from CVSROOT=anoncvs@anoncvs.xfree86.org:/cvs and will
give that
a shot tomarrow. For now 2.4.17 is fine.

-piet

> 
>
======================================
========
> 				/var/log/XFree86.0.log
>
======================================
========
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
> (II) PCI: 00:00:0: chip 8086,123d card 0000,0000 rev 01 class 08,00,20 hdr
00
> (II) PCI: 00:01:0: chip 1002,5245 card 1002,0008 rev 00 class 03,00,00 hdr
00
> (II) PCI: 00:03:0: chip 8086,7600 card 0000,0000 rev 01 class 06,01,00 hdr
80
> (II) PCI: 00:03:1: chip 8086,7601 card 8086,4253 rev 01 class 01,01,80 hdr
00
> (II) PCI: 00:03:2: chip 8086,7602 card 8086,4253 rev 01 class 0c,03,00 hdr
00
> (II) PCI: 00:03:3: chip 8086,7603 card 8086,4253 rev 01 class 0c,05,00 hdr
00
> .
> .
> .
> (II) PCI: 04:15:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr
80
> (II) PCI: 04:16:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr
80
> (II) PCI: 04:17:0: chip 8086,84e0 card 8086,84e0 rev 02 class 06,00,00 hdr
80
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
>
---------------------------------------------------------------------------
> I wonder if the error "(WW) Cannot open APM" is involved. I don't see
> a APM module in the kernel.
> 
> I searched RedHat's  Linux Support Knowledgebase but didn't find anything.
>
======================================
=============

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

