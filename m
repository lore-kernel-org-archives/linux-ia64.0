From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 11:57:17 +0000
Subject: [PATCH v2 3/3] checkpatch: add virt barriers
Message-Id: <1452427000-4520-4-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452427000-4520-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452427000-4520-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, Ton

Add virt_ barriers to list of barriers to check for
presence of a comment.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 scripts/checkpatch.pl | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index a96adcb..5ca272b 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5131,7 +5131,8 @@ sub process {
 		}x;
 		my $all_barriers = qr{
 			$barriers|
-			smp_($smp_barriers)
+			smp_($smp_barriers)|
+			virt_($smp_barriers)
 		}x;
 
 		if ($line =~ /\b($all_barriers)\s*\(/) {
-- 
MST

