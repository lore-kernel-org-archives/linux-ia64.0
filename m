From: "digiovanni, lucio" <digiovanni_lucio@emc.com>
Date: Tue, 22 Jul 2003 15:44:29 +0000
Subject: RE: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105888873611676@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Unfortunately I tried it on a DELL 3250 (Dual Itanium 2) running RH AS 2.1
updated to 2.4.18-e.31smp and also got a reboot!

-----Original Message-----
From: Bruno Cornec [mailto:Bruno.Cornec@hp.com]
Sent: Tuesday, July 22, 2003 8:33 AM
To: ia64-list
Cc: giovanni_pala@hp.com
Subject: a nice way to reboot :-)


Hello,

Intrigued by a problem reported by a customer (tar cf /dev/st0 /) and
remembering
another issue I had, I tried to investigate a bit and found the following.

On Linux/ia64 when you do cat /proc/kcore, the system just reboots in a
couple
of seconds (with RHAS 2.1 std kernel, updated kernel - 2.4.18-e.31) or even
with a=20
vanilla 2.4.21 + david's patches.
On Linux/i386, no such problem. As I have seen it on zx2000, rx4670, I think
it's
not an isolated case.=20

Could you confirm on other type of machines ? And more smarter people could
even=20
probably provide a patch.

Thanks in advance,
Bruno.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146
105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard
Grenoble/France
Des infos sur Linux?  http://www.HyPer-Linux.org
http://www.hp.com/linux
La musique ancienne?  http://www.musique-ancienne.org
http://www.medieval.org
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
