From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 26 Jul 2001 08:14:00 +0000
Subject: [Linux-ia64] kernel update (2nd patch relative to 2.4.7)
Message-Id: <marc-linux-ia64-105590693005922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.7-ia64-010726.diff*.

This patch is just a small update compared to the 010723 patch.  It
fixes the UP hang problem and has Alex' workaround for the Lion MADT
table bug.  Other assorted (small) patches are included too, though
you'll still need gcc3.0 for a successful compilation (or use Bills or
Keith's workaround for the Nov 17 compiler).

	--david

