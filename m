From: Andreas Schwab <schwab@suse.de>
Date: Sun, 02 Dec 2001 22:05:29 +0000
Subject: [Linux-ia64] Bug in signal handling
Message-Id: <marc-linux-ia64-105590698805573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The kernel does not correctly handle interrupted syscalls that are
supposed to be restarted when two nested signal handlers are executed at
the same time.  To reproduce run this program in one terminal:

#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

void
sigusr1 (int sig)
{
  write (2, "SIGUSR1\n", strlen ("SIGUSR1\n"));
}

void
sigusr2 (int sig)
{
  write (2, "SIGUSR2\n", strlen ("SIGUSR2\n"));
}

int
main ()
{
  char c;
  struct sigaction sa;

  printf ("%d\n", getpid ());
  sa.sa_handler =3D sigusr1;
  sigemptyset (&sa.sa_mask);
  sa.sa_flags =3D SA_RESTART;
  sigaction (SIGUSR1, &sa, NULL);
  sa.sa_handler =3D sigusr2;
  sigaction (SIGUSR2, &sa, NULL);
  read (1, &c, 1);
  return 0;
}

Then send both SIGUSR1 and SIGUSR2 to the process from another terminal.
If they arrive close enough then the first signal handler will be
interupted at GATE_ADDR by the second handler.  But ia64_do_signal is
again called with in_syscall =3D=3D 1, and it will call ia64_decrement_ip
before setting up the signal handler frame.  Thus when the second signal
returns then rt_sigreturn it will return to GATE_ADDR - 16 and crashes.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

