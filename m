From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 07 Feb 2006 03:25:55 +0000
Subject: [PATCH]Fix a possible buffer overflow in efi.c
Message-Id: <1139282755.8654.5.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a possible buffer overflow in efi.c
At lease the code logic is wrong.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup linux-2.6.15/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- linux-2.6.15/arch/ia64/kernel/efi.c	2006-02-06 07:57:06.000000000 +0800
+++ b/arch/ia64/kernel/efi.c	2006-02-08 04:19:56.000000000 +0800
@@ -432,7 +432,7 @@ efi_init (void)
 	/* Show what we know for posterity */
 	c16 = __va(efi.systab->fw_vendor);
 	if (c16) {
-		for (i = 0;i < (int) sizeof(vendor) && *c16; ++i)
+		for (i = 0;i < (int) sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = *c16++;
 		vendor[i] = '\0';
 	}







