From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Thu, 15 May 2003 08:37:40 +0000
Subject: [Linux-ia64] Itanium 2 flaw detection
Message-Id: <marc-linux-ia64-105590723705820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Concerning the recent problem announced by Intel on some I2 chips, do anyone
of you have a pointer to a script/C Code/whatever code which could give a
clear answer for the processor on which we are running ?
(I didn't had customer requests up yo now, but I prefer to be early :-)

Would it be also possible to include it in the result of /proc/cpuinfo as
it was done for pentium processor bugs some time ago:

[bruno@morley ~/Download]$ cat /proc/cpuinfo=20
[...]
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
[...]

Of course in case of answer for point 1, I could try to propose a patch for=
=20
point 2 (even if I never made kernel patches up to now).

TIA for any feedback,
Bruno.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146=
 105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard Grenoble/Fran=
ce
Des infos sur Linux?  http://www.HyPer-Linux.org      http://www.hp.com/lin=
ux
La musique ancienne?  http://www.musique-ancienne.org http://www.medieval.o=
rg

