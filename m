From: Peter Hurley <peter@hurleysoftware.com>
Date: Thu, 16 Oct 2014 19:10:53 +0000
Subject: [PATCH] ia64: Pin controlling tty for unaligned fault message
Message-Id: <1413486653-26010-1-git-send-email-peter@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Peter Hurley <peter@hurleysoftware.com>

Prevent destruction of the controlling tty before tty_write_message()
can determine if the tty is safe to use.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 arch/ia64/kernel/unaligned.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index 622772b..e7ae608 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -1336,8 +1336,11 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 			 * Don't call tty_write_message() if we're in the kernel; we might
 			 * be holding locks...
 			 */
-			if (user_mode(regs))
-				tty_write_message(current->signal->tty, buf);
+			if (user_mode(regs)) {
+				struct tty_struct *tty = get_current_tty();
+				tty_write_message(tty, buf);
+				tty_kref_put(tty);
+			}
 			buf[len-1] = '\0';	/* drop '\r' */
 			/* watch for command names containing %s */
 			printk(KERN_WARNING "%s", buf);
-- 
2.1.1

