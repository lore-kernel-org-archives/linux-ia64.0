From: Jay Lan <jlan@engr.sgi.com>
Date: Tue, 17 Oct 2006 01:51:56 +0000
Subject: Re: A regression in IA64 kexec/kdump patch for 2.6.18?
Message-Id: <4534373C.10407@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070802020304000405020701"
List-Id: <linux-ia64.vger.kernel.org>
References: <4533F2BE.3070300@engr.sgi.com>
In-Reply-To: <4533F2BE.3070300@engr.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070802020304000405020701
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Jay Lan wrote:
<snip>
> 
> Well, i built 2.6.18 kernel and 2.6.18rc5 kernels.
> I also built 2 kexec-tools based on kdump10 patch. I have been
> associating the kexec-tools tree that i built at the rc5 time with
> the rc5 kernel and the newer kexec-tools tree with the 2.6.18
> kernel.
> 
> I just ran a few tests with different combination of kexec-tools
> and kernels. Well, it showed that the rc5 version of kexec-tools
> worked correctly with both kernels, but the newer version of
> kexec-tools displayed the system restart problem with both kernels.
> 
> So, it was the kexec-tools that caused the problem. Not the kernel
> side. I will diff the patches i applied to both trees...

Nan-hai,

OK, the '-noio' option patch you posted on 9/20 was the cause of
my system restart.
http://lists.osdl.org/pipermail/fastboot/2006-September/004062.html

If instead, if i make every inline functions in
purgatory/arch/ia64/io.h null functions, it would then work.
I will attach the patch i used (based on your suggestion) here for
your reference. It was in rough form.


Thanks,
 - jay


> 
> Later,
>  - jay
> 
> 
> 
>>   Zou Nan hai
>>> Thanks,
>>>  - jay
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--------------070802020304000405020701
Content-Type: text/plain;
 name="kexec-ia64-reset-vga"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kexec-ia64-reset-vga"

Index: kexec-tools-1.101/purgatory/arch/ia64/io.h
===================================================================
--- kexec-tools-1.101.orig/purgatory/arch/ia64/io.h	2006-10-16 18:19:07.346416494 -0700
+++ kexec-tools-1.101/purgatory/arch/ia64/io.h	2006-10-16 18:47:14.742913628 -0700
@@ -4,6 +4,7 @@
 #define MF()	asm volatile ("mf.a" ::: "memory")
 #define IO_SPACE_ENCODING(p)     ((((p) >> 2) << 12) | (p & 0xfff))
 
+#ifdef DO_VGA_IO
 static inline void *io_addr (unsigned long port)
 {
         unsigned long offset;
@@ -91,4 +92,46 @@ static inline void writel(unsigned int b
 {
         *(volatile unsigned int *) addr = b;
 }
+#else
+static inline void *io_addr (unsigned long port)
+{ return (void*)0; }
+
+static inline unsigned int inb (unsigned long port)
+{ return 0; }
+
+static inline unsigned int inw (unsigned long port)
+{ return 0; }
+
+static inline unsigned int ia64_inl (unsigned long port)
+{ return 0; }
+
+static inline void outb (unsigned char val, unsigned long port)
+{ return; }
+
+static inline void outw (unsigned short val, unsigned long port)
+{ return; }
+
+static inline void outl (unsigned int val, unsigned long port)
+{ return; }
+
+
+static inline unsigned char readb(const volatile void  *addr)
+{ return 0; }
+
+static inline unsigned short readw(const volatile void  *addr)
+{ return 0; }
+
+static inline unsigned int readl(const volatile void  *addr)
+{ return 0; }
+
+static inline void writeb(unsigned char b, volatile void  *addr)
+{ return; }
+
+static inline void writew(unsigned short b, volatile void  *addr)
+{ return; }
+
+static inline void writel(unsigned int b, volatile void  *addr)
+{ return; }
+
+#endif
 #endif

--------------070802020304000405020701--
