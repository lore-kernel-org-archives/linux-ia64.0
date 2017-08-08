From: Helge Deller <deller@gmx.de>
Date: Tue, 08 Aug 2017 16:28:41 +0000
Subject: [PATCH] random: fix warning message on ia64 and parisc
Message-Id: <20170808162841.GA8668@p100.box>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Theodore Ts'o <tytso@mit.edu>, "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, torvalds@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-ia64@vger.kernel.org

Fix the warning message on the parisc and IA64 architectures to show the
correct function name of the caller by using %pS instead of %pF. The
message is printed with the value of _RET_IP_ which calls
__builtin_return_address(0) and as such returns the IP address caller
instead of pointer to a function descriptor of the caller.

The effect of this patch is visible on the parisc and ia64 architectures
only since those are the ones which use function descriptors while on
all others %pS and %pF will behave the same.

Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Jason A. Donenfeld <Jason@zx2c4.com>
Signed-off-by: Helge Deller <deller@gmx.de>
Fixes: eecabf567422 ("random: suppress spammy warnings about unseeded randomness")
Fixes: d06bfd1989fe ("random: warn when kernel uses unseeded randomness")

diff --git a/drivers/char/random.c b/drivers/char/random.c
index afa3ce7..8ad9270 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1492,7 +1492,7 @@ static void _warn_unseeded_randomness(const char *func_name, void *caller,
 #ifndef CONFIG_WARN_ALL_UNSEEDED_RANDOM
 	print_once = true;
 #endif
-	pr_notice("random: %s called from %pF with crng_init=%d\n",
+	pr_notice("random: %s called from %pS with crng_init=%d\n",
 		  func_name, caller, crng_init);
 }
 
