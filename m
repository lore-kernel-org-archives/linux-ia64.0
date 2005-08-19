From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 19 Aug 2005 23:43:15 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050819234315.GE6916@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Peter,

> 
>     
>     .bss
>     .align 16
> stack_mem:
>     .skip 16834
> 
> GLOBAL_ENTRY(_start)
> 	.prologue
> 	.save rp, r0
> 	.body
> 	movl gp = __gp
> 	movl sp = stack_mem
> 	bsw.1
> 	br.call.sptk.many rp=start_bootloader
> END(_start)
> 
> Doesn't the stack grow downwards on IA64? Shouldn't that be something
> like:

The memory stack grows down, the RBS grows up.

> 
> 	.bss
> 	.align 16
> rbs_mem:
> 	skip 18384-16
> stack_mem:
> 	skip 16
> 
> ????
> 
Ok, this change seems to work for both gcc-4.0 and gcc-3.3.5. So what this is saying
is that we got lucky with the older compilers that the variables were somehow laid out
slightly differently on the stack.

> I can't run ski at present to check it (it segfaults immediately)
> 
Well, that will be the next thing I need to check. It dies on both IA64 and I386?

The attached patch fixes the bootloader problem for me.

-- 

-Stephane

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bootloader-050819.diff"

--- arch/ia64/hp/sim/boot/boot_head.S.orig      2005-08-19 16:40:20.000000000 -0700
+++ arch/ia64/hp/sim/boot/boot_head.S   2005-08-19 16:40:25.000000000 -0700
@@ -7,8 +7,10 @@

        .bss
        .align 16
+rbs_mem:
+       .skip 18384-16
 stack_mem:
-       .skip 16834
+       .skip 16

        .text


--WIyZ46R2i8wDzkSu--
