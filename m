From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 18 Aug 2005 00:53:44 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050818005344.GN29115@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 16, 2005 at 03:46:47PM -0700, Luck, Tony wrote:
> And behind door number 3 is to fix the compiler ... but that also
> seems to be contentious (and doesn't help people who are already
> using gcc4).

I really wouldn't know where to start making the changes James
suggested, but if someone wants some help with running some benchmarks
or some hardware, I can help there.
 
> Is the simulator in error by only half loading when the structure
> is on a 4-byte boundary ... if so, then my 2nd choice would be to
> fix it there.

<squeaky wheel> HP, please give us the source for SKI </squeaky
wheel>. :)

> But ... since the fix is small, I could put it into the kernel
> as a last resort to get things working again.  Do you really need
> to align(16)? Or would (8) do?  A comment mentioning that this
> is a workaround for a compiler and/or simulator issue would be
> good.

It seems to want 16, 8 causes the same problem.  Below includes a
small comment.

Thanks,

-i

diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/bootloader.c
--- a/arch/ia64/hp/sim/boot/bootloader.c
+++ b/arch/ia64/hp/sim/boot/bootloader.c
@@ -30,10 +30,14 @@ struct disk_req {
 	unsigned len;
 };
 
+/* SSC_WAIT_COMPLETION appears to want this large alignment.  gcc < 4
+ * seems to give it by default, however gcc > 4 is smarter and may
+ * not.
+ */
 struct disk_stat {
 	int fd;
 	unsigned count;
-};
+} __attribute__ ((aligned (16)));
 
 extern void jmp_to_kernel (unsigned long bp, unsigned long e_entry);
 extern struct ia64_boot_param *sys_fw_init (const char *args, int arglen);

