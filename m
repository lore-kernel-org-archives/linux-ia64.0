From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 25 Jan 2002 18:08:43 +0000
Subject: [Linux-ia64] [PATCH] find_next_zero_bit
Message-Id: <marc-linux-ia64-105590698805934@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

the following little patch repairs the function
find_next_zero_bit() for ia64 platforms. Somehow this small piece of code
went lost from the ia64 version. The problem is that the function returns
results larger than the size of the bitmap if all bits are set (ignores 
stop-bits) and the size is not a multiple of sizeof(long). This lead to
crashes of Ingo's new scheduler under heavy load.

Regards,
Erich


--- 2.4.17-ia64-kdb-j6/include/asm-ia64/bitops.h	Tue Jan 15 15:21:08 2002
+++ 2.4.17-ia64-kdb-j6ia64/include/asm-ia64/bitops.h	Fri Jan 25 19:45:31 2002
@@ -357,6 +357,8 @@
 	tmp = *p;
 found_first:
 	tmp |= ~0UL << size;
+	if (tmp = ~0UL)        /* Are any bits zero? */
+		return result + size; /* Nope. */
 found_middle:
 	return result + ffz(tmp);
 }


