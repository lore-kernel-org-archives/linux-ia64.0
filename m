From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 12 Aug 2008 22:06:08 +0000
Subject: ia64 allmodconfig on current mainline
Message-Id: <20080812150608.231a948a.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

/opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/bin/ia64-unknown-linux-gnu-ld: section .data [0000000004ea0000 -> 0000000004f656e7] overlaps section .data.percpu [0000000004e90000 -> 0000000004ea0d17]
make: *** [.tmp_vmlinux1] Error 1
