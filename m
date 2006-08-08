From: Keith Owens <kaos@sgi.com>
Date: Tue, 08 Aug 2006 01:02:55 +0000
Subject: Re: Silent data corruption caused by XPC V2.
Message-Id: <5147.1154998975@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt (on Mon, 7 Aug 2006 12:49:33 -0500) wrote:
>Jack Steiner identified a problem where XPC can cause a silent
>data corruption.  On module load, the placement may cause the
>xpc_remote_copy_buffer to span two physical pages.  DMA transfers are
>done to the start virtual address translated to physical.
>
>This patch changes the buffer from a statically allocated buffer to a
>kmalloc'd buffer.  Dean Nelson reviewed this before posting.  I have
>tested it in the configuration that was showing the memory corruption
>and verified it works.  I also added DBUG_ON statements to help catch
>this if a similar situation is encountered.
>
>Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
>=================================>--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2006-08-07 12:37:56.187180666 -0500
>+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2006-08-07 12:37:58.935517909 -0500
>@@ -274,6 +274,7 @@ xpc_pull_remote_cachelines(struct xpc_pa
> 	DBUG_ON((u64) src != L1_CACHE_ALIGN((u64) src));
> 	DBUG_ON((u64) dst != L1_CACHE_ALIGN((u64) dst));
> 	DBUG_ON(cnt != L1_CACHE_ALIGN(cnt));
>+	DBUG_ON((ia64_tpa(dst) + cnt) != ia64_tpa(&((char *) dst)[cnt]));

Can the byte count be greater than 2 pages?  If it can, then that debug
statement is not going to catch this case:

Virtual page         Physical page

   A                    X
   A+1                  Y
   A+2                  X+2

because you only test the last page.


FWIW, I find this more readable instead of indexing then taking the
address of the result.

   DBUG_ON((ia64_tpa(dst) + cnt) != ia64_tpa((char *) dst + cnt);

