From: Andreas Schwab <schwab@suse.de>
Date: Mon, 17 Sep 2001 14:12:34 +0000
Subject: [Linux-ia64] sigaltstack not working
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
Message-Id: <marc-linux-ia64-105590698805189@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

The appended program isn't working as expected.  As soon as the stack
limit is reached it hangs without actually executing the signal handler.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

--=-=-=
Content-Disposition: attachment; filename=sigaltstack.c

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <sys/types.h>
#include <sys/resource.h>

sigjmp_buf mainloop;

volatile int pass = 0;

void
stackoverflow_handler (int sig)
{
  pass++;
  printf ("Stack overflow %d caught.\n", pass);
  siglongjmp (mainloop, pass);
}

int
recurse (int n)
{
  printf ("%p\n", &n);
  if (n >= 0)
    return n + recurse (n + 1);
  else
    return 0;
}

int
main ()
{
  char mystack[16384];
  struct rlimit rl;
  stack_t ss;
  struct sigaction action;

  rl.rlim_cur = rl.rlim_max = 0x100000;	/* 1 MB */
  setrlimit (RLIMIT_STACK, &rl);
  ss.ss_sp = mystack;
  ss.ss_size = sizeof (mystack);
  ss.ss_flags = 0;
  if (sigaltstack (&ss, (stack_t *) 0) < 0)
    exit (0);

  action.sa_handler = stackoverflow_handler;
  action.sa_flags = SA_ONSTACK;
  sigemptyset (&action.sa_mask);
  if (sigaction (SIGSEGV, &action, 0) < 0)
    exit (0);

  switch (sigsetjmp (mainloop, 1))
    {
    case 0:
    case 1:
      printf ("Starting recursion pass %d.\n", pass + 1);
      recurse (0);
      printf ("no endless recursion?!\n");
      exit (1);

    case 2:
      printf ("Test passed.\n");
      exit (0);

    default:
      abort ();
    }
}

--=-=-=--

