From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Mar 2004 05:58:51 +0000
Subject: kernel update (relative to v2.6.4)
Message-Id: <200403120558.i2C5wp4a010686@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6 in file:

  linux-2.6.4-ia64-040311.diff.gz

Apart from syncing with 2.6.4, this contains various small bug fixes.
If you use ia64 linux on a workstation, I'd definitely recommend using
this patch because it fixes some nasty races in the OHCI USB driver
(used on most HP machines, for example) and a bug in the HID input
driver which could cause a CPU to get stuck when connecting certain
USB devices.  Also, I think Ken's fix for the softirq handling
unexpectedly fixed some sound play-back issues (it's always nice when
a fix shows up before the problem is even tracked down... ;-).

Oh, due to Matthew's patch to switch over to drivers/Kconfig, you'll
have to type "n" a lot when doing "make oldconfig" for the Ski
simulator.  But that should be a one-time event and it's all for the
better.  If you're lazy, you could try:

	$ yes n | make oldconfig

Just don't sue me if this yields a non-working kernel!

Enjoy,

	--david
