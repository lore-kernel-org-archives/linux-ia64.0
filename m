From: Maciej Golebiewski <maciej@ccrl-nece.technopark.gmd.de>
Date: Mon, 15 Jan 2001 10:17:31 +0000
Subject: Re: [Linux-ia64] /proc/pid/mem and stack variables
Message-Id: <marc-linux-ia64-105590693005041@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Jan 12, 2001 at 06:29:33PM -0800, David Mosberger wrote:
> >>>>> On Fri, 12 Jan 2001 13:45:10 -0500, Pete Wyckoff <pw@osc.edu> said:
> Yes, implementing llseek for fs/proc/base.c:proc_mem_operations is the
> right solution.  /dev/kmem already has its own llseek (which treats
> the offset as unsigned) but, for some reason, was left out of the
> /proc/pid/mem support.
>=20
> Don, can you add this to the TODO list so we won't forget about it?

Thanks a lot for help. It seems that the solution is simpler than I
was expecting. Anyway, I don't have a root access to the IA64 machine
in question, so I can't test it myself, but one of the guys with root
access told me he'll try to find some time and try it out.

Once again thank a lot.

Maciej

--=20
Maciej Go=B3=EAbiewski
golebiewski@ccrl-nece.de
http://www.ccrl-nece.technopark.gmd.de/~maciej
C&C Research Laboratories, NEC Europe Ltd., Sankt Augustin, Germany

