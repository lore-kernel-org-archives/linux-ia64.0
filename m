From: Randolph Chung <randolph@tausq.org>
Date: Wed, 03 Oct 2001 18:26:44 +0000
Subject: [Linux-ia64] X4.1.0 reboots and log
Message-Id: <marc-linux-ia64-105590698805295@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Like David mentioned in a previous email I've also seen random reboots
when switching between a vt and X (4.1.0, as packaged in Debian's woody
distribution). I've also seen this sometimes when leaving X running
overnight (with xscreensaver kicking in). This is on a HP i2000 smp
system, with a nvidia quadro pro card. (no glx)

One thing I noticed is that the crashes seem to coincide with certain
messages in the event log. I've posted an excerpt at
http://gandalf.tausq.org/tmp/kern.log

Does this help anyone debug the problem? I was told that this:

Oct  2 12:16:52 pippin kernel: +Platform PCI Component Error Info
Section
Oct  2 12:16:52 pippin kernel: + PCI Component Error Detail:  Error
Status: 0x1000
Oct  2 12:16:52 pippin kernel:  Component Info: Vendor Id = 0x8086,
Device Id = 0x84e0, Class Code = 0x0, Seg/Bus/Dev/Func = 4/0/0/6

corresponds to a "address above top of memory" error reported by the SAC, but
don't know how to trace this down more.

help appreciated,
randolph
-- 
   @..@                                         http://www.TauSq.org/
  (----)
 ( >__< )
 ^^ ~~ ^^

