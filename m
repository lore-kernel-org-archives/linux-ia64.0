From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 18 Apr 2001 07:05:03 +0000
Subject: Re: [Linux-ia64] One other question
Message-Id: <marc-linux-ia64-105590693005421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005419@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005419@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Apr 2001 23:21:03 -0700, Stephane Eranian <eranian@frankl.hpl.hp.com> said:

  Stephane> Hi, On Tue, Apr 17, 2001 at 10:11:19PM -0700, Weihaw
  Stephane> CHUANG wrote:
  >> In regards to my previous email.
  >> 
  >> What I'm really trying to get at is, is there a method to single
  >> step instructions with user level interrupts?

  Stephane> I believe you can simply do this using the ptrace() system
  Stephane> call and giving it the PTRACE_SINGLESTEP command. Look at
  Stephane> arch/ia64/kernel/ptrace.c for more details.

That's correct.  I'm attaching a small test program I wrote a while
ago.  It shows how to single step individual instructions, basic
blocks, and system calls.

	--david

/*
    utrace -- micro tracing tool 
    Copyright (C) 1999-2001  Hewlett-Packard Company
    Contributed by David Mosberger-Tang <davidm@hpl.hp.com>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
    02111-1307 USA
*/

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/ptrace.h>
#include <sys/wait.h>

char *prog_name;

#if defined(__ia64__)

#include <asm/fpu.h>
#include <asm/ptrace.h>
#include <asm/ptrace_offsets.h>
#include <asm/rse.h>

int singlestep;

static inline double
fpreg_to_double (struct ia64_fpreg *fp)
{
  double result;

  asm ("ldf.fill %0=%1" : "=f"(result) : "m"(*fp));
  return result;
}

void
print_syscall (int child_pid, int state)
{
  long scnum, result, error, val;
#if 0
  struct ia64_fpreg fp;
#endif
  unsigned long bsp;
  int i;

  if (state = 0)
    return;

  errno = 0;
  scnum = ptrace (PTRACE_PEEKUSER, child_pid, PT_R15, 0);
  result = ptrace (PTRACE_PEEKUSER, child_pid, PT_R8, 0);
  error = ptrace (PTRACE_PEEKUSER, child_pid, PT_R10, 0);
  bsp = ptrace (PTRACE_PEEKUSER, child_pid, PT_AR_BSP, 0);

#if 0
  fp.u.bits[0] = ptrace (PTRACE_PEEKUSER, child_pid, PT_F32 + 0, 0);
  fp.u.bits[1] = ptrace (PTRACE_PEEKUSER, child_pid, PT_F32 + 8, 0);
  printf ("f32=%f\n", fpreg_to_double (&fp));
#endif

  if (errno)
    {
      printf ("%s: ptrace() failed, errno=%d\n", prog_name, errno);
      return;
    }
  printf ("<sc%04ld(", scnum);

  for (i = 0; i < 4; ++i)
    {
      val = ptrace (PTRACE_PEEKDATA, child_pid,
		    (long) ia64_rse_skip_regs ((long *) bsp, i), 0);
      printf ("%lx,", val);
    }

  if (error)
    printf ("...) -> errno=%ld\n", result);
  else
    printf ("...) -> %ld\n", result);
}

void
print_state (int child_pid, int with_slot)
{
  long ip, slot;

  ip = ptrace (PTRACE_PEEKUSER, child_pid, PT_CR_IIP, 0);
  if (with_slot)
    {
      slot = (ptrace (PTRACE_PEEKUSER, child_pid, PT_CR_IPSR, 0) >> 41) & 0x3;
      printf ("%016lx:%ld\n", ip, slot);
    }
  else
    printf ("%016lx\n", ip);
}

#elif defined(__i386__)

void
print_syscall (int child_pid, int state)
{
  int scnum, result;

  scnum = ptrace (PTRACE_PEEKUSER, child_pid, 11*4, 0);	/* read EAX */
  errno = 0;
  result = ptrace (PTRACE_PEEKUSER, child_pid, 6*4, 0);	/* read ORIG_EAX */

  if (result = -ENOSYS)
    return;

  if (errno)
    {
      printf ("%s: ptrace() failed, errno=%d\n", prog_name, errno);
      return;
    }
  printf ("<sc%03d>() -> %d\n", scnum, result);
}

#else
# error Sorry, you're architecture isn't supported.
#endif

int
main (int argc, char **argv, char **envp)
{
  int status, pid, child_pid, state = 1, arg;

  prog_name = argv[0];

  if (argc < 2 || strcmp (argv[1], "-h") = 0)
    {
      printf ("Usage: %s [-abB] command args...\n", prog_name);
      printf ("  -a: trace instruction execution\n");
      printf ("  -b: trace basic block execution\n");
      printf ("  -s: trace system call execution (default)\n");
      exit (-1);
    }

  arg = 1;
  if (strcmp (argv[arg], "-a") = 0)
    {
      singlestep = 1;
      ++arg;
    }
  if (strcmp (argv[arg], "-b") = 0)
    {
      singlestep = 2;
      ++arg;
    }
  if (strcmp (argv[arg], "-s") = 0)
    {
      singlestep = 0;
      ++arg;
    }

  child_pid = fork ();
  if (child_pid = 0)
    {
      ptrace (PTRACE_TRACEME, 0, 0, 0);
      execve (argv[arg], argv + arg, envp);
      printf ("%s: execve failed (errno=%d)\n", prog_name, errno);
      exit (-2);
    }

  while (1)
    {
      pid = wait4 (-1, &status, 0, 0);
      if (pid = -1)
	{
	  if (errno = EINTR)
	    continue;

	  printf ("%s: wait4() failed (errno=%d)\n", prog_name, errno);
	}
      if (WIFSIGNALED (status) || WIFEXITED (status)
	  || (WIFSTOPPED (status) && WSTOPSIG (status) != SIGTRAP))
	{
	  if (WIFEXITED (status))
	    {
	      printf ("%s: exit status %d\n", prog_name, WEXITSTATUS (status));
	      break;
	    }
	  else if (WIFSIGNALED (status))
	    {
	      printf ("%s: terminated by signal %d\n",
		      prog_name, WTERMSIG (status));
	    }
	  else
	    printf ("%s: got signal %d\n", prog_name, WSTOPSIG (status));
	}

      if (singlestep)
	{
	  /* single stepping through program: */
	  if (singlestep = 2)
	    {
	      print_state (child_pid, 0);
	      ptrace (PTRACE_SINGLEBLOCK, child_pid, 0, 0);
	    }
	  else
	    {
	      print_state (child_pid, 1);
	      ptrace (PTRACE_SINGLESTEP, child_pid, 0, 0);
	    }
	}
      else
	{
	  /* syscall tracing */
	  print_syscall (child_pid, state);
	  state = (state + 1) & 1;
	  ptrace (PTRACE_SYSCALL, child_pid, 0, 0);		/* continue */
	}
    }
  return 0;
}


