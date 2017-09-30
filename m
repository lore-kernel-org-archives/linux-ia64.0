From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Sat, 30 Sep 2017 02:53:19 +0000
Subject: [PATCHv3 7/7] checkpatch: add pF/pf deprecation warning
Message-Id: <20170930025319.987-8-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joe Perches <joe@perches.com>, Andy Whitcroft <apw@canonical.com>

We deprecated '%pF/%pf' printk specifiers, since '%pS/%ps' is now smart
enough to handle function pointer dereference on platforms where such
dereference is required.

checkpatch warning example:

WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Joe Perches <joe@perches.com>
Cc: Andy Whitcroft <apw@canonical.com>
Tested-by: Helge Deller <deller@gmx.de> # parisc64
Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
Tested-by: Tony Luck <tony.luck@intel.com> # ia64
---
 scripts/checkpatch.pl | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 03eb2551477d..387c453413e0 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5762,18 +5762,25 @@ sub process {
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
+				my $ext_type = "Invalid";
+				my $use = "";
 				for (my $count = $linenr + 1; $count <= $lc; $count++) {
 					$stat_real = $stat_real . "\n" . raw_line($count, 0);
 				}
+				if ($bad_extension =~ /p[Ff]/) {
+					$ext_type = "Deprecated";
+					$use = " - use %pS instead";
+					$use =~ s/pS/ps/ if ($bad_extension =~ /pf/);
+				}
 				WARN("VSPRINTF_POINTER_EXTENSION",
-				     "Invalid vsprintf pointer extension '$bad_extension'\n" . "$here\n$stat_real\n");
+				     "$ext_type vsprintf pointer extension '$bad_extension'$use\n" . "$here\n$stat_real\n");
 			}
 		}
 
-- 
2.14.2

