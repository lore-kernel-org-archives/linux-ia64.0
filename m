From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 19:45:33 +0000
Subject: megaraid warnings
Message-Id: <16434.28509.327706.76307@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The 2.6 megaraid driver causes several ugly warnings along the lines of:

drivers/scsi/megaraid.c:3500: warning: cast to pointer from integer of different size

I think those may be harmless (I don't have hardware to test this) but
it would still be better to fix the drivers so there are no warnings
(most likely by casting u32 addresses that are guaranteed to be <4GB
to "unsigned long" before converting them to a pointer).

Can someone look into this?

Thanks,

	--david
