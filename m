From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 04 Jan 2016 11:37:00 +0000
Subject: [PATCH 2/3] checkpatch: check for __smp outside barrier.h
Message-Id: <1451907395-15978-3-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451907395-15978-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, "Cc : Andy Whitcroft" <apw@canonical.com>, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew

Introduction of __smp barriers cleans up a bunch of duplicate code, but
it gives people an additional handle onto a "new" set of barriers - just
because they're prefixed with __* unfortunately doesn't stop anyone from
using it (as happened with other arch stuff before.)

Add a checkpatch test so it will trigger a warning.

Reported-by: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 scripts/checkpatch.pl | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 0245bbe..e3f9ad9 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5130,6 +5130,17 @@ sub process {
 			}
 		}
 
+		my @underscore_smp_barriers = map {"__" . $_} @smp_barriers;
+		my $underscore_all_barriers = join('|', @underscore_smp_barriers);
+
+		if ($realfile !~ m@^include/asm-generic/@ &&
+		    $realfile !~ m@/barrier\.h$@ &&
+		    $line =~ m/\b($underscore_all_barriers)\(/ &&
+		    $line !~ m/^.\s*\#\s*define\s+($underscore_all_barriers)\(/) {
+			WARN("MEMORY_BARRIER",
+			     "__smp memory barriers shouldn't be used outside barrier.h and asm-generic\n" . $herecurr);
+		}
+
 # check for waitqueue_active without a comment.
 		if ($line =~ /\bwaitqueue_active\s*\(/) {
 			if (!ctx_has_comment($first_line, $linenr)) {
-- 
MST

