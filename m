From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Oct 2003 18:47:04 +0000
Subject: [PATCH 2.4 and 2.6] infinite loop in ia64_mca_wakeup_ipi_wait
Message-Id: <marc-linux-ia64-106607084613856@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This bugfix has been hiding inside the MCA TLB patches.

There is an infinite loop in ia64_mca_wakeup_ipi_wait() because
the compiler optimizes away the test at the bottom of the while
loop.  It does this because IA64_MCA_WAKEUP_VECTOR is 0xf0, so
irr_bit is known to be the constant 0x30, a.k.a. 48 in decimal.
So when the compiler looks at the expression:

	while (!(irr & (1 << irr_bit)))

It observes that "1" (an *integer* constant) shifted left by 48
bits is 0, and so the value of "irr" becomes irrelevent.

The fix is to make sure that the compiler treats the "1" as unsigned
long:

--- old/arch/ia64/kernel/mca.c	2003-10-13 11:20:08.885518014 -0700
+++ new/arch/ia64/kernel/mca.c	2003-10-13 11:20:31.427509925 -0700
@@ -828,7 +828,7 @@
 			irr = ia64_getreg(_IA64_REG_CR_IRR3);
 			break;
 		}
-	} while (!(irr & (1 << irr_bit))) ;
+	} while (!(irr & (1UL << irr_bit))) ;
 }
 
 /*
