From: Francis Galiegue <fg@mandrakesoft.com>
Date: Mon, 26 Feb 2001 13:18:11 +0000
Subject: [Linux-ia64] The sys_nanosleep "bug", more details
Message-Id: <marc-linux-ia64-105590693005203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

After investigating a little, I found that the process is stuck in...
schedule()! And always in S state, not D state, so I can C-c it whenever I
want...

More strange: if I suspend the process using C-z and put it to the foregrou=
nd
again, it completes...

Looking at the schedule() code right now...

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


