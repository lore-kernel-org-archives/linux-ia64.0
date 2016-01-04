From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 04 Jan 2016 11:37:08 +0000
Subject: [PATCH 3/3] checkpatch: add virt barriers
Message-Id: <1451907395-15978-4-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451907395-15978-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451907395-15978-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, Tony Lindgren <tony@atomide.com>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Andrey Konovalov <andreyknvl@google.com>, adi-buildroot-devel@lists.sourceforge.net, "Cc : Andy Whitcroft" <apw@canonical.com>, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew

Add virt_ barriers to list of barriers to check for
presence of a comment.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 scripts/checkpatch.pl | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index e3f9ad9..5fb6ef7 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5121,7 +5121,8 @@ sub process {
 		my @smp_barriers = ('smp_store_release', 'smp_load_acquire', 'smp_store_mb');
 
 		@smp_barriers = (@smp_barriers, map {"smp_" . $_} @barriers);
-		my $all_barriers = join('|', (@barriers, @smp_barriers));
+		my @virt_barriers = map {my $l = $_; $l =~ s/smp_/virt_/; $l} @smp_barriers;
+		my $all_barriers = join('|', (@barriers, @smp_barriers, @virt_barriers));
 
 		if ($line =~ /\b($all_barriers)\(/) {
 			if (!ctx_has_comment($first_line, $linenr)) {
-- 
MST

