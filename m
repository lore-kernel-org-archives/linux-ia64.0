From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Feb 2004 07:06:09 +0000
Subject: kernel update (relative to 2.6.3)
Message-Id: <16435.3809.866678.776335@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I updated the ia64 patch for 2.6.3.  It's in the usual place:

 ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.6/

in file:

 linux-2.6.3-ia64-040217.diff.gz

Thanks to Linus' very recent syncing the patch is currently down to
basically the EARLY_PRINTK support.  In other words, Linus' 2.6.3
should work quite well for ia64 as is.  Perhaps that's a sign that
it's time for 2.7 to open up? ;-)

Enjoy,

	--david
