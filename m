From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue, 14 Oct 2008 01:54:55 +0000
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit compile failure
Message-Id: <20081014015455.GA25385@susedev.qlogic.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081013060615.GB29358@colo.lackof.org> <20081012.230939.240550430.davem@davemloft.net>
In-Reply-To: <20081012.230939.240550430.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: grundler@parisc-linux.org, linux-driver@qlogic.com, netdev@vger.kernel.org, linux-ia64@vger.kernel.org

Dave/Grant,
I sent this earlier today but didn't see it on the netdev list.
Thanks, Ron

This ASIC does support all page sizes. For 4k and 8k page size the TX control block needs an external scatter gather list.  For page sizes larger than 8k the max frags is satisfied by the original TX control block.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c37ea43..38116f9 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -58,7 +58,7 @@
  */
 #if (PAGE_SHIFT = 12) || (PAGE_SHIFT = 13)	/* 4k & 8k pages */
 #define TX_DESC_PER_OAL ((MAX_SKB_FRAGS - TX_DESC_PER_IOCB) + 2)
-#elif (PAGE_SHIFT = 16)	/* 64k pages */
+#else /* all other page sizes */
 #define TX_DESC_PER_OAL 0
 #endif
 
-- 
1.6.0

