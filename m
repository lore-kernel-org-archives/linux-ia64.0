From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Mon, 11 Oct 2021 15:25:36 +0000
Subject: [PATCH v1 09/10] lkdtm: Fix lkdtm_EXEC_RODATA()
Message-Id: <7da92e59e148bd23564d63bdd8bcfaba0ba6d1f1.1633964380.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1633964380.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Behind a location, lkdtm_EXEC_RODATA() executes a real function,
not a copy of do_nothing().

So do it directly instead of using execute_location().

And fix displayed addresses by dereferencing the function descriptors.

Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 drivers/misc/lkdtm/perms.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 442d60ed25ef..da16564e1ecd 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -153,7 +153,14 @@ void lkdtm_EXEC_VMALLOC(void)
 
 void lkdtm_EXEC_RODATA(void)
 {
-	execute_location(lkdtm_rodata_do_nothing, CODE_AS_IS);
+	pr_info("attempting ok execution at %px\n",
+		dereference_symbol_descriptor(do_nothing));
+	do_nothing();
+
+	pr_info("attempting bad execution at %px\n",
+		dereference_symbol_descriptor(lkdtm_rodata_do_nothing));
+	lkdtm_rodata_do_nothing();
+	pr_err("FAIL: func returned\n");
 }
 
 void lkdtm_EXEC_USERSPACE(void)
-- 
2.31.1
