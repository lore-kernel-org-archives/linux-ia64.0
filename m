From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Mar 2003 23:40:02 +0000
Subject: [Linux-ia64] [patch] fix for ia64_get_unaligned()/ia64_put_unaligned() macros
Message-Id: <marc-linux-ia64-105590723705287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64_get_unaligned() and ia64_put_unaligned() macros use names for
temporary variables that are likely to clash with existing
variable-names.  Patch below fixes this.  The patch also sanitizes the
names of the helper-routines (and their arguments).

Bjorn, the patch is relative to 2.5.64, but I think it should apply on
2.4 as well.

	--david

=== include/asm-ia64/unaligned.h 1.2 vs edited ==--- 1.2/include/asm-ia64/unaligned.h	Mon Feb  4 23:43:07 2002
+++ edited/include/asm-ia64/unaligned.h	Fri Mar 21 15:36:32 2003
@@ -7,8 +7,8 @@
  * The main single-value unaligned transfer routines.  Derived from
  * the Linux/Alpha version.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #define get_unaligned(ptr) \
 	((__typeof__(*(ptr)))ia64_get_unaligned((ptr), sizeof(*(ptr))))
@@ -16,110 +16,105 @@
 #define put_unaligned(x,ptr) \
 	ia64_put_unaligned((unsigned long)(x), (ptr), sizeof(*(ptr)))
 
-/*
- * EGCS 1.1 knows about arbitrary unaligned loads.  Define some
- * packed structures to talk about such things with.
- */
 struct __una_u64 { __u64 x __attribute__((packed)); };
 struct __una_u32 { __u32 x __attribute__((packed)); };
 struct __una_u16 { __u16 x __attribute__((packed)); };
 
 static inline unsigned long
-__uldq (const unsigned long * r11)
+__uld8 (const unsigned long * addr)
 {
-	const struct __una_u64 *ptr = (const struct __una_u64 *) r11;
+	const struct __una_u64 *ptr = (const struct __una_u64 *) addr;
 	return ptr->x;
 }
 
 static inline unsigned long
-__uldl (const unsigned int * r11)
+__uld4 (const unsigned int * addr)
 {
-	const struct __una_u32 *ptr = (const struct __una_u32 *) r11;
+	const struct __una_u32 *ptr = (const struct __una_u32 *) addr;
 	return ptr->x;
 }
 
 static inline unsigned long
-__uldw (const unsigned short * r11)
+__uld2 (const unsigned short * addr)
 {
-	const struct __una_u16 *ptr = (const struct __una_u16 *) r11;
+	const struct __una_u16 *ptr = (const struct __una_u16 *) addr;
 	return ptr->x;
 }
 
 static inline void
-__ustq (unsigned long r5, unsigned long * r11)
+__ust8 (unsigned long val, unsigned long * addr)
 {
-	struct __una_u64 *ptr = (struct __una_u64 *) r11;
-	ptr->x = r5;
+	struct __una_u64 *ptr = (struct __una_u64 *) addr;
+	ptr->x = val;
 }
 
 static inline void
-__ustl (unsigned long r5, unsigned int * r11)
+__ust4 (unsigned long val, unsigned int * addr)
 {
-	struct __una_u32 *ptr = (struct __una_u32 *) r11;
-	ptr->x = r5;
+	struct __una_u32 *ptr = (struct __una_u32 *) addr;
+	ptr->x = val;
 }
 
 static inline void
-__ustw (unsigned long r5, unsigned short * r11)
+__ust2 (unsigned long val, unsigned short * addr)
 {
-	struct __una_u16 *ptr = (struct __una_u16 *) r11;
-	ptr->x = r5;
+	struct __una_u16 *ptr = (struct __una_u16 *) addr;
+	ptr->x = val;
 }
 
 
 /*
- * This function doesn't actually exist.  The idea is that when
- * someone uses the macros below with an unsupported size (datatype),
- * the linker will alert us to the problem via an unresolved reference
- * error.
+ * This function doesn't actually exist.  The idea is that when someone uses the macros
+ * below with an unsupported size (datatype), the linker will alert us to the problem via
+ * an unresolved reference error.
  */
 extern unsigned long ia64_bad_unaligned_access_length (void);
 
-#define ia64_get_unaligned(_ptr,size)				\
-({								\
-	const void *ptr = (_ptr);				\
-	unsigned long val;					\
-								\
-	switch (size) {						\
-	      case 1:						\
-		val = *(const unsigned char *) ptr;		\
-		break;						\
-	      case 2:						\
-		val = __uldw((const unsigned short *)ptr);	\
-		break;						\
-	      case 4:						\
-		val = __uldl((const unsigned int *)ptr);	\
-		break;						\
-	      case 8:						\
-		val = __uldq((const unsigned long *)ptr);	\
-		break;						\
-	      default:						\
-		val = ia64_bad_unaligned_access_length();	\
-	}							\
-	val;							\
+#define ia64_get_unaligned(_ptr,size)						\
+({										\
+	const void *__ia64_ptr = (_ptr);					\
+	unsigned long __ia64_val;						\
+										\
+	switch (size) {								\
+	      case 1:								\
+		__ia64_val = *(const unsigned char *) __ia64_ptr;		\
+		break;								\
+	      case 2:								\
+		__ia64_val = __uld2((const unsigned short *)__ia64_ptr);	\
+		break;								\
+	      case 4:								\
+		__ia64_val = __uld4((const unsigned int *)__ia64_ptr);		\
+		break;								\
+	      case 8:								\
+		__ia64_val = __uld8((const unsigned long *)__ia64_ptr);		\
+		break;								\
+	      default:								\
+		__ia64_val = ia64_bad_unaligned_access_length();		\
+	}									\
+	__ia64_val;								\
 })
 
-#define ia64_put_unaligned(_val,_ptr,size)		\
-do {							\
-	const void *ptr = (_ptr);			\
-	unsigned long val = (_val);			\
-							\
-	switch (size) {					\
-	      case 1:					\
-		*(unsigned char *)ptr = (val);		\
-	        break;					\
-	      case 2:					\
-		__ustw(val, (unsigned short *)ptr);	\
-		break;					\
-	      case 4:					\
-		__ustl(val, (unsigned int *)ptr);	\
-		break;					\
-	      case 8:					\
-		__ustq(val, (unsigned long *)ptr);	\
-		break;					\
-	      default:					\
-	    	ia64_bad_unaligned_access_length();	\
-	}						\
+#define ia64_put_unaligned(_val,_ptr,size)				\
+do {									\
+	const void *__ia64_ptr = (_ptr);				\
+	unsigned long __ia64_val = (_val);				\
+									\
+	switch (size) {							\
+	      case 1:							\
+		*(unsigned char *)__ia64_ptr = (__ia64_val);		\
+	        break;							\
+	      case 2:							\
+		__ust2(__ia64_val, (unsigned short *)__ia64_ptr);	\
+		break;							\
+	      case 4:							\
+		__ust4(__ia64_val, (unsigned int *)__ia64_ptr);		\
+		break;							\
+	      case 8:							\
+		__ust8(__ia64_val, (unsigned long *)__ia64_ptr);	\
+		break;							\
+	      default:							\
+	    	ia64_bad_unaligned_access_length();			\
+	}								\
 } while (0)
 
 #endif /* _ASM_IA64_UNALIGNED_H */

