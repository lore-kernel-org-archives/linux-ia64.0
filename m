From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 11 Mar 2003 22:37:37 +0000
Subject: [Linux-ia64] bogus __clear_bit macro
Message-Id: <marc-linux-ia64-105590709806037@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kenneth" = Kenneth W Chen <Chen> writes:

Kenneth> David,
Kenneth> It looks like when __clear_bit() was implemented, the deletion of the macro falls through the crack.  This macro prohibit the actual __clear_bit to be invoked.


While you're fixing bitops.h, making test_bit take a const qualified
arg will kill some warnings in reiserfs...

--- /tmp/geta24522      2003-03-12 09:19:31.000000000 +1100
+++ linux/include/asm-ia64/bitops.h    2003-03-12 09:17:53.000000000 +1100
@@ -275,7 +275,7 @@
 }

 static __inline__ int
-test_bit (int nr, volatile void *addr)
+test_bit (int nr, const volatile void *addr)
 {
	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
 }

