From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Sep 2003 07:03:43 +0000
Subject: kernel update (relative to 2.6.0-test5)
Message-Id: <marc-linux-ia64-106309120628711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch relative to 2.6.0-test5 is available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5
in:

	linux-2.6.0-test5-ia64-030908.diff.gz

It's primarily bug fixes and syncing with 2.6.0-test5.  Oh,
fadvise64_64() turned out to be a brain-fart for ia64 (it isn't
needed), so it's gone again from the ia64 syscall table.

Sadly, the NFS server still appears to be broken.

	--david
