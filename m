From: Francis Galiegue <fg@mandrakesoft.com>
Date: Mon, 12 Feb 2001 12:03:23 +0000
Subject: [Linux-ia64] Pagesize bug vs. libpthread bug :(
Message-Id: <marc-linux-ia64-105590693005132@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I've succeeded in compiling and installing the CVS version of glibc dated
20010208, but since then all programs using libpthread segfault. This inclu=
des
all fileutils, among others. Fortunately I have a "stable" glibc installed =
in
my chroot and so can export LD_LIBRARY_PATH to point to them, so my system =
is
still usable.

But that won't solve at all this pagesize problem. Hence my question: is th=
ere a
patch somewhere that makes programs linked statically with libnss work (hen=
ce
rpm) applying over *stock* glibc 2.2? I hate to have to choose between two
bugs, but I'd rather have ls, mv, etc work... And I'm not knowledgeable abo=
ut
glibc internals at all...

Please help :(

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


