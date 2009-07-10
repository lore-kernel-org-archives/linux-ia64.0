From: Ali Polatel <polatel@gmail.com>
Date: Fri, 10 Jul 2009 16:06:03 +0000
Subject: sydbox and ia64
Message-Id: <20090710160603.GE749@harikalardiyari>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="hHWLQfXTYDoKhP50"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi everyone,
Sydbox is a ptrace based sandboxing application. Basically it checks
system call arguments for path prefixes and allows/denies them by
comparing them to a whitelist. So far it has support for x86 and x86_64
architectures.

I'm trying to port it to IA64 architecture. Only ptrace() involved
functions=B9 needs to be ported, namely:
trace_get_syscall: Get system call number (done)
trace_set_syscall: Set system call number (done)
trace_get_return: Get system call return value (done but not tested)
trace_set_return: Set system call return value (done but not tested)
trace_get_string: Get a string argument of the system call (done)

These functions more or less work fine, the two functions i need help
with are:
trace_set_string: Set a string argument of the system call.
  This function is used to change some path arguments to /dev/null so
  that the application running under sydbox thinks everything is fine
  but in reality it writes to /dev/null, not the actual file. We call
  this write predicted paths.
trace_fake_stat: Fake stat buffer of stat() call.
  This function is used to implement the so-called magic commands.
  When run under sydbox the stat()'ing the path /dev/sydbox returns the
  faked stat buffer, not the actual one (which is failure because it
  doesn't exist.)

Both of these functions use ptrace(PTRACE_POKEDATA, ...) to poke data to
child's memory area and both of these functions don't work as expected.
I suspect additional hackery is involved to make them work. I'd
appreciate if anyone with knowledge about ptrace() and itanium
processors be kind enough to look at this file and tell me what's wrong
:-].
Thanks in advance.


=B9: These functions reside in trace.c which you can see here:
   http://github.com/alip/sydbox/blob/ia64/src/trace.c
   For those who want to clone the repository, the git url is:
   git://github.com/alip/sydbox.git

--=20
Regards,
Ali Polatel

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)

iEYEABECAAYFAkpXZusACgkQQU4yORhF8iDQogCguJqrlVIKbdQj38eWl7KgqAoA
Xl4AoMg+8rEdMQUQlb7i2ucJ02h+M0Xy
=G7z2
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
