From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 10 Jun 2004 05:16:05 +0000
Subject: wait4 causes segfault in i386 chroot
Message-Id: <20040610051605.GA21936@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

We just upgraded a box from 2.4 -> 2.6.7-rc3 and now we are seeing a
strange wait problem in a 386 chroot environment.  The initial problem
was that I could chroot into the directory where the 386 install is
kept, but as soon as whatever I ran from the shell prompt completed
the shell got a segv.  This happened with both bash and csh, but not
when you directed bash to exec something directly with a -c flag.

I've tracked it down to doing a wait/waitpid/wait4 (they all end up in
wait4) in a sigchld signal handler.  If I do a minimal test case where
I catch the sigchld and wait, once the call returns it segfaults as in
this trace (gdb can't seem to give a good backtrace).

[pid  8192] exit_group(1)               =3D ?  <-- child exits
Process 8192 detached
<... nanosleep resumed> 0xbffffbe4)     =3D ? ERESTART_RESTARTBLOCK (To be =
restarted)
--- SIGCHLD (Child exited) @ 0 (0) ---
wait4(-1, [{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 1}], WNOHANG, NULL) =3D 8=
192
--- SIGSEGV (Segmentation fault) @ 0 (0) ---
+++ killed by SIGSEGV +++

However, if you do the wait in the parent directly it works fine!

Anyone have any ideas?

-i

--- minimal test program ---
#include <stdio.h>
#include <wait.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>

int pid;

void sigchld_handler (int signum)
{
	int pid, status;
	while (!(pid =3D wait4(WAIT_ANY, &status, WNOHANG, NULL))) {
		if (pid < 0) {
			perror ("waitpid");
			break;
		}
		if (pid =3D=3D 0)
			break;
	}
}

int main(int argc, char *argv[]) {

  int pid, status;

  signal(SIGCHLD, sigchld_handler);
 =20
  if ((pid =3D fork()) =3D=3D -1)
	  exit(1);
 =20
  //child
  else if (pid =3D=3D 0) { =20
	  sleep(2);
	  exit(1);
  }
 =20
  //parent
  else {
	  //remove the sigchld handler and=20
          //replace this with wait/waitpid/wait4()=20
	  //and everything is fine
	  sleep(10);
  }
 =20
return 0;

}

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAx+6UWDlSU/gp6ecRAoMLAJ9sEBdXip3iVLTeWRrLZMeyazDjEQCfXTHX
OwwsAnv8OhvXu7GvmPL/oKo=
=LCEN
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--
