From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Feb 2002 07:02:31 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.3)
Message-Id: <marc-linux-ia64-105590698806028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A quick patch relative to v2.5.3 is now at ftp.CC.kernel.org
in /pub/linux/kernel/ports/ia64/v2.5/:

 linux-2.5.3-ia64-020207.gz

It's mostly a sync up with the many v2.5.3 changes plus assorted other
patches folks have sent me over the last couple of days and weeks
(including a large perfmon update from Stephane).

Caveats: this should give you a working kernel for the HP simulator
and Big Sur, but I have tried SMP only and haven't done a lot of
testing.  I think NFS may be broken at the moment.  Also, this kernel
by default turns off execute permission on the stack and data
segments.  For applications that (incorrectly) assume that data is
executable by default, a workaround can be enabled by turning on a bit
in the ELF executable header.  The attached program can be used to
manipulate the bit in question.

IMPORTANT: The current XFree86 server suffers from the problem of assuming
data is executable.  To fix this, run the command:

	# chatr -E /usr/X11R6/bin/XFree86

and you should be all set.

Enjoy,

	--david

<-- chatr.c --><-- chatr.c --><-- chatr.c --><-- chatr.c -->
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

