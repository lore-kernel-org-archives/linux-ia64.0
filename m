From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 16 Nov 2000 23:30:12 +0000
Subject: [Linux-ia64] Re: [ia64-tools] Re: Re: Re: Re: Re: Re: toolchain status
Message-Id: <marc-linux-ia64-105590678205737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 16, 2000 at 01:43:22PM -0800, Richard Henderson wrote:
> On Thu, Nov 16, 2000 at 10:53:45AM -0800, H . J . Lu wrote:
> > There is no DT_INIT_ARRAY in libc.so. Even if there is DT_INIT_ARRAY,
> > I still don't know how to use it to tell where DT_INIT points to.
> 
> Easy enough -- you know from DT_PLTGOT what the GP is for the DSO.
> If *(long *)(DT_INIT + 8) = GP, then you can assume that DT_INIT
> is a descriptor instead of an offset.
> 

Thanks. This patch seems to work for me.

-- 
H.J. Lu (hjl@valinux.com)
---
2000-11-16  H.J. Lu  <hjl@gnu.org>

	* sysdeps/ia64/dl-lookupcfg.h (DL_DT_INIT_ADDRESS): Check if
	*(long *)(DT_INIT + 8) = GP to tell a descriptor from an
	offset. It is for the backward compatibility.
	(DL_DT_FINI_ADDRESS): Likewise.

Index: sysdeps/ia64/dl-lookupcfg.h
=================================RCS file: /work/cvs/gnu/glibc/sysdeps/ia64/dl-lookupcfg.h,v
retrieving revision 1.1.1.4
diff -u -p -r1.1.1.4 dl-lookupcfg.h
--- sysdeps/ia64/dl-lookupcfg.h	2000/11/16 18:49:34	1.1.1.4
+++ sysdeps/ia64/dl-lookupcfg.h	2000/11/16 23:25:42
@@ -40,5 +40,13 @@ extern Elf64_Addr _dl_function_address (
 					Elf64_Addr start);
 
 #define DL_FUNCTION_ADDRESS(map, addr) _dl_function_address (map, addr)
+#if 0
 #define DL_DT_INIT_ADDRESS(map, addr) DL_FUNCTION_ADDRESS (map, addr)
 #define DL_DT_FINI_ADDRESS(map, addr) DL_FUNCTION_ADDRESS (map, addr)
+#else
+/* When should this backward compatibility be removed? */
+#define DL_DT_INIT_ADDRESS(map, addr)					      \
+  ((map)->l_info[DT_PLTGOT]->d_un.d_ptr = *(Elf64_Addr *) ((addr) + 8)       \
+   ? (addr) : DL_FUNCTION_ADDRESS (map, addr))
+#define DL_DT_FINI_ADDRESS(map, addr) DL_DT_INIT_ADDRESS (map, addr)
+#endif

