From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Feb 2002 01:47:27 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905193@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch is now availabe at ftp.CC.kernel.org
in /pub/linux/kernel/ports/ia64/v2.4/:

 linux-2.4.18-ia64-020226.gz

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

Other than that, here is a summary of changes (my apologies if I
missed anything or misattributed a patch):

	- better ia64 IRQ affinity support (Erich Focht)
	- include Firewire configuration for ia64 (Bdale Garbee/Grant Grundler)
	- fix ia32 GDT initialization (Don Dugger)
	- implement ia32 emulation for SIOCGIFCONF (Don Dugger)
	- make page fault handler pass reason for a SIGSEGV/SIGILL in
	  siginfo.si_isr (see include/asm-ia64/siginfo.h for details)
	- /proc/efivars update (Matt Domsch)
	- fix I/O SAPIC irq routing (makes ACPI power button events work)
	  (J.I. Lee)
	- fix exception handler to not assume that archdata_start is
	  non-NULL for all modules (Bjorn Helgaas)
	- don't define _HAVE_ARCH_IPV6_CSUM as we don't really have it
	  (Bdale Garbee/Grant Grunderl)
	- drop .bias from ld4.bias instruction in spinlock code to avoid
	  CPU errata (Asit Mallick)
	- MCA update (Jenna Hall)
	- update perfmon to v1.0 (Stephane Eranian)
	- add PTRACE_GETREGS/PTRACE_SETREGS (Yoav Zach)
	- fix handling of .label_state/.copy_state in kernel unwinder
	- move initial kernel stack from region 4 down to region 3
	- bump gcc3.x inlining threshold to 2000 to get things to
	  compile with gcc3.1
	- don't make ia64 stack and data executable by default and
	  drop lazy-execute bit support; restore original interface
	  for page-fault handler
	- fix clone2() stack initialization bug found by Asit Mallick
	- fix siginfo kernel data leaking
	- fix alternate TLB miss handlers to not lose Exception Deferral bit

This patch has been tested on Big Sur and HP Ski simulator in SMP and
UP and with gcc3.0 and gcc2.96.  YMMV.

Oh, I also included in the ia64 patch the personality fix which was
accidentally got dropped from 2.4.18 (it was in -rc4).  Also, I synced
the drm-4.0 code with Marcelo's tree, but I haven't done any testing
on it.

Enjoy,

	--david

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
	      (ehdr.e_flags & EF_IA_64_LINUX_EXECUTABLE_STACK) ? "yes" : "no");
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

