From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 24 Jan 2002 19:46:33 +0000
Subject: [Linux-ia64] Patch to fix latest kernels issue with FW83
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C1A50F.D35D63D0"
Message-Id: <marc-linux-ia64-105590698805927@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C1A50F.D35D63D0
Content-Type: text/plain;
	charset="ISO-8859-1"

We have root caused the stability problem with latest kernels and FW83 (LION
platform). The following patch (based on 2.4.17) fixes the problem. Please
let me know if you still see a problem after applying this patch.

Thanks,
Asit
 <<patch.FW83>> 
--- /home1/src/linux/include/asm-ia64/spinlock.h    Wed Jan  9 19:25:05 2002
+++ linux/include/asm-ia64/spinlock.h   Wed Jan 23 15:52:45 2002
@@ -84,7 +84,7 @@
    "mov r29 = 1\n"                     \
    ";;\n"                          \
    "1:\n"                          \
-   "ld4.bias r2 = [%0]\n"                  \
+   "ld4 r2 = [%0]\n"                   \
    ";;\n"                          \
    "cmp4.eq p0,p7 = r0,r2\n"               \
    "(p7) br.cond.spnt.few 1b \n"               \


------_=_NextPart_000_01C1A50F.D35D63D0
Content-Type: application/octet-stream;
	name="patch.FW83"
Content-Disposition: attachment;
	filename="patch.FW83"

--- /home1/src/linux/include/asm-ia64/spinlock.h	Wed Jan  9 19:25:05 2002
+++ linux/include/asm-ia64/spinlock.h	Wed Jan 23 15:52:45 2002
@@ -84,7 +84,7 @@
 	"mov r29 = 1\n"						\
 	";;\n"							\
 	"1:\n"							\
-	"ld4.bias r2 = [%0]\n"					\
+	"ld4 r2 = [%0]\n"					\
 	";;\n"							\
 	"cmp4.eq p0,p7 = r0,r2\n"				\
 	"(p7) br.cond.spnt.few 1b \n"				\

------_=_NextPart_000_01C1A50F.D35D63D0--

