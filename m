From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 16 Aug 2001 05:11:00 +0000
Subject: [Linux-ia64] kernel patch with updated DRM (relative to 2.4.8)
Message-Id: <marc-linux-ia64-105590698805086@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, Chris' mega patch finally made it and I updated the kernel patch
at ftp.kernel.org:/pub/linux/kernel/ports/ia64/ accordingly.  That directory
now contains:

	linux-2.4.8-ia64-010815.diff.gz

Which is the complete ia64 patch relative to the official 2.4.8 tree.

Apart from the DRM update, I fixed the semicolon typo that prevented
compilation with older compilers and I also added rwlock_init().

Enjoy,

	--david

