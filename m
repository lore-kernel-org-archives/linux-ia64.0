From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Thu, 17 Apr 2003 19:21:48 +0000
Subject: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

We're using Oracle 9iRAC on Linux I2 for a proof of concept and are having
one issue.

Sometimes the Oracle process dies with the following error message:

Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist fault at ip=
 40000000048b4562

The ip address is always the same. This happens on all of our 4 nodes
as it seems randomly. I do not have other debug info as this is the only
message printed. Some times for the same process the message is printed=20
up to 4 times.

Kernel used: 2.4.18-e.25 (RedHat update) based on 2.4.18 + a lot of patches
making it difficult to match with David's releases.

The error message is a printk warning in traps.c.

Any idea on what can cause it, and how we could debug more the context ?
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

