From: Francis Galiegue <fg@mandrakesoft.com>
Date: Mon, 26 Feb 2001 12:52:05 +0000
Subject: [Linux-ia64] 2.4.1 + 010131 patch: sys_nanosleep sleeps... infinitely!
Message-Id: <marc-linux-ia64-105590693005202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is on a single B2 step CPU BigSur, 1G RAM, with kernel version mention=
ed
in subject. In order to prevent too long fscks on hangs, I did a little scr=
ipt
which syncs and then sleeps for 1 sec, infinitely. At some point which I co=
uld
not isolate, sys_nanosleep would sleep forever....

Anyone else having hit that problem?

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


