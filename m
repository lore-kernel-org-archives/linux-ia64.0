From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Wed, 14 Jul 2004 01:07:06 +0000
Subject: [PATCH] 2.6.8-rc1 including AFS in ia64 and other ARCHS builds breaks the compilation
Message-Id: <20040714010706.GA31683@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ia64 Linux <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: dhowells@redhat.com

Including Andrew File System on any arch other
than i386 and x86_64 will break the compilation
due to the use of 'struct_cpy()', which is only
define in the two archs above and both archs
define it differently:
i386:
#define struct_cpy(x,y) 			\
({						\
	if (sizeof(*(x)) != sizeof(*(y))) 	\
		__struct_cpy_bug();		\
	memcpy(x, y, sizeof(*(x)));		\
})

x86_64:
#define struct_cpy(x,y) (*(x)=*(y))

both in include/asm/string.h

A quick discussion here suggests that we are not
doing a deep copy of the struct though others
may by able to enlighten us on what happens to
pointers within a struct?

I have applied the i386 definition to ia64 and
compiles OK, though I cannot test it since I
do not have direct access to AFS. 

diff -Nru a/include/asm-ia64/string.h b/include/asm-ia64/string.h
--- a/include/asm-ia64/string.h 2004-07-14 10:54:17 +10:00
+++ b/include/asm-ia64/string.h 2004-07-14 10:54:17 +10:00
@@ -20,4 +20,19 @@
 extern void *memcpy (void *, const void *, __kernel_size_t);
 extern void *memset (void *, int, __kernel_size_t);
  
+
+/*
+ * struct_cpy(x,y), copy structure *x into (matching structure) *y.
+ *
+ * We get link-time errors if the structure sizes do not match.
+ * There is no runtime overhead, it's all optimized away at
+ * compile time.
+ */
+#define struct_cpy(x,y)                        \
+({                                             \
+       if (sizeof(*(x)) != sizeof(*(y)))       \
+               __struct_cpy_bug();             \
+       memcpy(x, y, sizeof(*(x)));             \
+})
+
 #endif /* _ASM_IA64_STRING_H */

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
