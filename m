From: Adam Buchbinder <adam.buchbinder@gmail.com>
Date: Wed, 24 Feb 2016 18:50:29 +0000
Subject: [PATCH] ia64: Fix misspellings in comments.
Message-Id: <1456339829-4234-1-git-send-email-adam.buchbinder@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Adam Buchbinder <adam.buchbinder@gmail.com>
---
 arch/ia64/include/asm/sn/ioc3.h   | 2 +-
 arch/ia64/include/asm/sn/shubio.h | 4 ++--
 arch/ia64/kernel/efi.c            | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/sn/ioc3.h b/arch/ia64/include/asm/sn/ioc3.h
index 95ed6cc..6eaa3cc 100644
--- a/arch/ia64/include/asm/sn/ioc3.h
+++ b/arch/ia64/include/asm/sn/ioc3.h
@@ -131,7 +131,7 @@ struct ioc3 {
 #define SSCR_PAUSE_STATE	0x40000000	/* set when PAUSE takes effect*/
 #define SSCR_RESET		0x80000000	/* reset DMA channels */
 
-/* all producer/comsumer pointers are the same bitfield */
+/* all producer/consumer pointers are the same bitfield */
 #define PROD_CONS_PTR_4K	0x00000ff8	/* for 4K buffers */
 #define PROD_CONS_PTR_1K	0x000003f8	/* for 1K buffers */
 #define PROD_CONS_PTR_OFF	3
diff --git a/arch/ia64/include/asm/sn/shubio.h b/arch/ia64/include/asm/sn/shubio.h
index ecb8a49..8a1ec13 100644
--- a/arch/ia64/include/asm/sn/shubio.h
+++ b/arch/ia64/include/asm/sn/shubio.h
@@ -1385,7 +1385,7 @@ typedef union ii_ibcr_u {
  * respones are captured until IXSS[VALID] is cleared by setting the    *
  * appropriate bit in IECLR. Every time a spurious read response is     *
  * detected, the SPUR_RD bit of the PRB corresponding to the incoming   *
- * message's SIDN field is set. This always happens, regarless of       *
+ * message's SIDN field is set. This always happens, regardless of       *
  * whether a header is captured. The programmer should check            *
  * IXSM[SIDN] to determine which widget sent the spurious response,     *
  * because there may be more than one SPUR_RD bit set in the PRB        *
@@ -2997,7 +2997,7 @@ typedef union ii_ippr_u {
 /*
  * Values for field imsgtype
  */
-#define IIO_ICRB_IMSGT_XTALK    0	/* Incoming Meessage from Xtalk */
+#define IIO_ICRB_IMSGT_XTALK    0	/* Incoming message from Xtalk */
 #define IIO_ICRB_IMSGT_BTE      1	/* Incoming message from BTE    */
 #define IIO_ICRB_IMSGT_SN1NET   2	/* Incoming message from SN1 net */
 #define IIO_ICRB_IMSGT_CRB      3	/* Incoming message from CRB ???  */
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index caae3f4..b52a074 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -966,7 +966,7 @@ efi_uart_console_only(void)
 /*
  * Look for the first granule aligned memory descriptor memory
  * that is big enough to hold EFI memory map. Make sure this
- * descriptor is atleast granule sized so it does not get trimmed
+ * descriptor is at least granule sized so it does not get trimmed
  */
 struct kern_memdesc *
 find_memmap_space (void)
-- 
2.7.0.rc3.207.g0ac5344

