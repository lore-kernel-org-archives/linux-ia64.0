From: Gwenole Beauchesne <gbeauchesne@mandrakesoft.com>
Date: Thu, 27 Dec 2001 14:34:34 +0000
Subject: Re: [Linux-ia64] eepro100 hang?
Message-Id: <marc-linux-ia64-105590698805722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 7 Dec 2001, Ville Herva wrote:

> Is this supposed to be fixed?

Bill Nottingham reported the following:
<https://external-lists.valinux.com/archives/linux-ia64/2001-October/002312=
.html>

<quote>
The HW has a bug.

You need to run eepro100-diag -f -G -w -w -w  to fix it.
You can get eepro100-diag from ftp.scyld.com; it's one of Donald Becker's
diagnostic tools.
</quote>

On IA-64, I explicitly use the e100 driver for the following:
0x8086  0x1229  "e100"  "Intel Corporation|82559 [Ethernet Pro 100]"
0x8086  0x2449  "e100"  "Intel Corporation|EtherExpress PRO/100"

> Mandrake ftp installation stalled in the middle, and when I straced the
> process from shell, it seemed to be loading rpm from ftp server, but the
> read always returned 1 byte, and and it took about half a second to do so.

Strange. I never tried FTP installations on an HP i2000 but full installs
through NFS sure did work on this machine. FTP installs also work on our
Lions btw. Have you tried with another FTP server?

Bye,
Gwenol=E9.


