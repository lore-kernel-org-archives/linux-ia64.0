From: Joshua Aas <josha@sgi.com>
Date: Thu, 15 Jul 2004 14:39:36 +0000
Subject: Re: clean up comments in arch/ia64/mm/init.c
Message-Id: <40F69728.6080002@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060201000804080708020309"
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5AE74.10308@sgi.com>
In-Reply-To: <40F5AE74.10308@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060201000804080708020309
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

David Mosberger wrote:
>>>>>>On Wed, 14 Jul 2004 17:06:44 -0500, Joshua Aas <josha@sgi.com> said:
> 
> 
>   Joshua> While working on another patch in arch/ia64/mm/init.c, I
>   Joshua> found a comment that doesn't seem to make sense and one that
>   Joshua> just has a minor whitespace problem. The problem with the
>   Joshua> comment after setup_gate() is that boot memory seems to have
>   Joshua> already been freed a few lines earlier in the function and
>   Joshua> nothing else happens in mem_init() after the call to
>   Joshua> setup_gate() (unless compiling for IA32).  If there aren't
>   Joshua> any objections, it would be nice to have this patch applied
>   Joshua> so as not to confuse people in the future.
> 
> -EPATCHDOESNTAPPLY.
> 
> I think your mailer mangles whitespace.  Try sending it as a MIME
> attachement.
> 
> 	--david

Patch is attached.

Signed-off-by: Josh Aas <josha@sgi.com>

-- 
Josh Aas
Silicon Graphics, Inc. (SGI)
Linux System Software
651-683-3068

--------------060201000804080708020309
Content-Type: text/x-patch;
 name="init.c.comments.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="init.c.comments.patch"

--- a/arch/ia64/mm/init.c	2004-06-16 00:19:22.000000000 -0500
+++ b/arch/ia64/mm/init.c	2004-07-14 16:50:59.000000000 -0500
@@ -169,7 +169,7 @@ free_initrd_mem (unsigned long start, un
 {
 	struct page *page;
 	/*
-	 * EFI uses 4KB pages while the kernel can use 4KB  or bigger.
+	 * EFI uses 4KB pages while the kernel can use 4KB or bigger.
 	 * Thus EFI and the kernel may have different page sizes. It is
 	 * therefore possible to have the initrd share the same page as
 	 * the end of the kernel (given current setup).
@@ -580,7 +580,7 @@ mem_init (void)
 		if (!fsyscall_table[i] || nolwsys)
 			fsyscall_table[i] = sys_call_table[i] | 1;
 	}
-	setup_gate();	/* setup gate pages before we free up boot memory... */
+	setup_gate();
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_boot_gdt_init();

--------------060201000804080708020309--
