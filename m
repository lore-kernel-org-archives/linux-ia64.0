From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Tue, 22 Jul 2003 12:32:54 +0000
Subject: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105887789030732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Intrigued by a problem reported by a customer (tar cf /dev/st0 /) and remem=
bering
another issue I had, I tried to investigate a bit and found the following.

On Linux/ia64 when you do cat /proc/kcore, the system just reboots in a cou=
ple
of seconds (with RHAS 2.1 std kernel, updated kernel - 2.4.18-e.31) or even=
 with a=20
vanilla 2.4.21 + david's patches.
On Linux/i386, no such problem. As I have seen it on zx2000, rx4670, I thin=
k it's
not an isolated case.=20

Could you confirm on other type of machines ? And more smarter people could=
 even=20
probably provide a patch.

Thanks in advance,
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
