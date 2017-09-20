From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 20 Sep 2017 16:29:09 +0000
Subject: [RFC][PATCH v2 7/7] checkpatch: add pF/pf deprecation warning
Message-Id: <20170920162910.32053-8-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>

We deprecated '%pF/%pf' printk specifiers, since '%pS/%ps' is now smart
enough to handle function pointer dereference on platforms where such
dereference is required.

checkpatch warning example:

WARNING: Use '%pS/%ps' instead. This pointer extension was deprecated: '%pF'

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andy Whitcroft <apw@canonical.com>
Cc: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index dd2c262aebbf..5945e4843466 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5762,18 +5762,20 @@ sub process {
 		        for (my $count = $linenr; $count <= $lc; $count++) {
 				my $fmt = get_quoted_string($lines[$count - 1], raw_line($count, 0));
 				$fmt =~ s/%%//g;
-				if ($fmt =~ /(\%[\*\d\.]*p(?![\WFfSsBKRraEhMmIiUDdgVCbGNO]).)/) {
+				if ($fmt =~ /(\%[\*\d\.]*p(?![\WSsBKRraEhMmIiUDdgVCbGNO]).)/) {
 					$bad_extension = $1;
 					last;
 				}
 			}
 			if ($bad_extension ne "") {
 				my $stat_real = raw_line($linenr, 0);
+				my $error_msg = "Invalid vsprintf pointer extension ";
 				for (my $count = $linenr + 1; $count <= $lc; $count++) {
 					$stat_real = $stat_real . "\n" . raw_line($count, 0);
 				}
+				$error_msg = "Use '%pS/%ps' instead. This pointer extension was deprecated:" if ($bad_extension =~ /pF|pf/);
 				WARN("VSPRINTF_POINTER_EXTENSION",
-				     "Invalid vsprintf pointer extension '$bad_extension'\n" . "$here\n$stat_real\n");
+				     "$error_msg '$bad_extension'\n" . "$here\n$stat_real\n");
 			}
 		}
 
-- 
2.14.1

