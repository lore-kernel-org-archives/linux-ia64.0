From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:26:28 +0000
Subject: [PATCH 3/7] - New SN hardware support - boot_init_shub2
Message-Id: <20050811172628.GA18265@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Update the addresses of the pio_write_status_addr so that
they are correct for newer processors. Shub2 did not number
the threads in the order that I had expected.


	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-08-09 16:01:51.326485822 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-08-10 15:01:16.539344428 -0500
@@ -532,8 +532,8 @@ void __init sn_cpu_init(void)
 	 */
 	{
 		u64 pio1[] = {SH1_PIO_WRITE_STATUS_0, 0, SH1_PIO_WRITE_STATUS_1, 0};
-		u64 pio2[] = {SH2_PIO_WRITE_STATUS_0, SH2_PIO_WRITE_STATUS_1,
-			SH2_PIO_WRITE_STATUS_2, SH2_PIO_WRITE_STATUS_3};
+		u64 pio2[] = {SH2_PIO_WRITE_STATUS_0, SH2_PIO_WRITE_STATUS_2,
+			SH2_PIO_WRITE_STATUS_1, SH2_PIO_WRITE_STATUS_3};
 		u64 *pio;
 		pio = is_shub1() ? pio1 : pio2;
 		pda->pio_write_status_addr = (volatile unsigned long *) LOCAL_MMR_ADDR(pio[slice]);
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


