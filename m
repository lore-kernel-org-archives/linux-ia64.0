From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jan 2004 00:13:02 +0000
Subject: old tulip patch
Message-Id: <200401130013.i0D0D2F6012444@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'd like to remove the attached old patch from my linux-ia64-2.5 tree.
If anybody thinks it's still needed, please speak up now.

Thanks,

	--david

diff -Nru a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c	Mon Jan 12 15:37:12 2004
+++ b/drivers/net/tulip/media.c	Mon Jan 12 15:37:12 2004
@@ -278,6 +278,10 @@
 				for (i = 0; i < init_length; i++)
 					outl(init_sequence[i], ioaddr + CSR12);
 			}
+
+			(void) inl(ioaddr + CSR6); /* flush CSR12 writes */
+			udelay(500);		/* Give MII time to recover */
+
 			tmp_info = get_u16(&misc_info[1]);
 			if (tmp_info)
 				tp->advertising[phy_num] = tmp_info | 1;
