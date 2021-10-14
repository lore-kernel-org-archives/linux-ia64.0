From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Thu, 14 Oct 2021 05:49:58 +0000
Subject: [PATCH v2 09/13] lkdtm: Force do_nothing() out of line
Message-Id: <44c2261293843b71cd0a7f485f889dd51deb5fe7.1634190022.git.christophe.leroy@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634190022.git.christophe.leroy@csgroup.eu>
In-Reply-To: <cover.1634190022.git.christophe.leroy@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

LKDTM tests display that the run do_nothing() at a given
address, but in reality do_nothing() is inlined into the
caller.

Force it out of line so that it really runs text at the
displayed address.

Acked-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
---
 drivers/misc/lkdtm/perms.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 2dede2ef658f..60b3b2fe929d 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -21,7 +21,7 @@
 /* This is non-const, so it will end up in the .data section. */
 static u8 data_area[EXEC_SIZE];
 
-/* This is cost, so it will end up in the .rodata section. */
+/* This is const, so it will end up in the .rodata section. */
 static const unsigned long rodata = 0xAA55AA55;
 
 /* This is marked __ro_after_init, so it should ultimately be .rodata. */
@@ -31,7 +31,7 @@ static unsigned long ro_after_init __ro_after_init = 0x55AA5500;
  * This just returns to the caller. It is designed to be copied into
  * non-executable memory regions.
  */
-static void do_nothing(void)
+static noinline void do_nothing(void)
 {
 	return;
 }
-- 
2.31.1
