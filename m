From: Francis Galiegue <fg@mandrakesoft.com>
Date: Tue, 27 Mar 2001 13:36:36 +0000
Subject: [Linux-ia64] Bug in dynamic linker (glibc 2.2.2)
Message-Id: <marc-linux-ia64-105590693005357@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Well, at least, the dynamic linker says it has a bug, but I don't know whet=
her
it's actually the linker or another component. Bug shows on ia64 but not on
Alpha, x86, Sparc{,64} nor PPC.

The bug: when building qt 2.3.0, using libmng 1.0.0, when it comes to build=
 the
designer, this error occurs when it tries to run uic:

BUG IN DYNAMIC LINKER ld.so: dl-version.c: 217: _dl_check_map_versions:
Assertion `needed !=3D ((void *)0)' failed!

I made a foo test program which only uses mng_version_text() of said librar=
y,
tried to link and run it and... it succeeds!

Second thing which I've tried: update my toolchain RPM with RedHat patches,
recompiled libmng with it, then retried qt. Same result.

All calls to ldd uic croak with the same error as well. But calling ldd on =
foo
succeeds.

I noticed that RedHat fisher uses mng 0.9.4 instead of 1.0.0, and this is w=
hat
I will try right now. Has anyone else encountered this bug? What can I do to
chase it down?

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


