From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 01 Nov 2002 06:18:57 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.45)
Message-Id: <marc-linux-ia64-105590709805321@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 patch is now at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
in file:

	linux-2.5.45-ia64-021031.diff.gz

Apart from various fixes and sync-ups (see log at
http://lia64.bkbits.net:8080/to-linus-2.5 for details), the most
notable change is that the per-CPU data area is now always 64KB in
size, no matter what the normal page size.  This was needed because a
per-CPU data structure in the scheduler is very large (>4KB), so a
single page was no longer sufficient.

This patch has been tested on Ski simulator, Big Sur (2-way), and
zx2000 (1-way).

Enjoy,

	--david

PS: Don't try to build the NFS v4 server---it doesn't build.  Also,
    "make xconfig" now requires a ton of Qt libraries.  "make menuconfig"
    works pretty much as usual, though.

