From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Jun 2004 01:15:41 +0000
Subject: kernel update (relative to 2.6.7, second try)
Message-Id: <16610.5181.264565.782457@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a quick update before disappearing (again) for a few days (this
time it's vacation at least... ;-):

The latest ia64 patch can now be found at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file:

 linux-2.6.7-ia64-040629.diff.gz

This should hopefully fix most, if not all, the boot-problems that the
original 2.6.7 patch has caused.  Perhaps SN2 machines still don't
work (?) but all the machines and configurations I have tried seem to
be fine again (Big Sur, UP/MP zx6000/rx2600, UP/MP 4-way rx5670, Ski
simulator).  Thanks to Ken for the good work on tracking down this
nasty bug!

Hopefully, your mileage will vary at lot less this time.

Enjoy,

	--david
