From: Andrew Morton <akpm@osdl.org>
Date: Sat, 18 Sep 2004 05:11:08 +0000
Subject: Re: Unaligned kernel access in crypto/sha1.c
Message-Id: <20040917221108.32545506.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040916231638.GA32514@lucon.org>
In-Reply-To: <20040916231638.GA32514@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. J. Lu" <hjl@lucon.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"H. J. Lu" <hjl@lucon.org> wrote:
>
> I got
> 
> Sep 16 15:45:32 gnu-2 kernel: kernel unaligned access to
> 0xa0000002001c008e, ip=0xa0000001002135e0
> Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> 0xa0000002002d005e, ip=0xa0000001002135e0
> Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> 0xa0000002002d006e, ip=0xa0000001002135e0
> Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> 0xa0000002002d007e, ip=0xa0000001002135e0
> Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> 0xa0000002002d008e, ip=0xa0000001002135e0
> 
> on ia64 from sha1_transform in crypto/sha1.c:
> 
> /* Hash a single 512-bit block. This is the core of the algorithm. */
> static void sha1_transform(u32 *state, const u8 *in)
> {
>         u32 a, b, c, d, e;
>         u32 block32[16];
>                                                                                 
>         /* convert/copy data to workspace */
>         for (a = 0; a < sizeof(block32)/sizeof(u32); a++)
>           block32[a] = be32_to_cpu (((const u32 *)in)[a]);
> 				     ^^^^^^^^^^^^^^^^
> 				 This may not be aligned for u32 on ia64.
> 
> 

We really need to know the call trace here.

--- 25/arch/ia64/kernel/unaligned.c~ia64-alignment-error-stack-dump	2004-09-17 22:10:14.933111832 -0700
+++ 25-akpm/arch/ia64/kernel/unaligned.c	2004-09-17 22:10:35.903923784 -0700
@@ -1342,9 +1342,11 @@ ia64_handle_unaligned (unsigned long ifa
 			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %s */
 		}
 	} else {
-		if (within_logging_rate_limit())
+		if (within_logging_rate_limit()) {
 			printk(KERN_WARNING "kernel unaligned access to 0x%016lx, ip=0x%016lx\n",
 			       ifa, regs->cr_iip + ipsr->ri);
+			dump_stack();
+		}
 		set_fs(KERNEL_DS);
 	}
 
_

