From: Bob Montgomery <bob.montgomery@hp.com>
Date: Fri, 11 Mar 2005 22:46:46 +0000
Subject: [PATCH]  Enhanced show_stack output to add backing store regs
Message-Id: <1110581206.498.109.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks to the list for all the comments so far.

Here is the patch that adds the register backing store display to
ia64_do_show_stack.  Note that the new routine "borrows" the line buffer
created in ia64_do_show_stack by requiring the caller to pass a pointer
and a size.  I wanted to avoid growing the stack unnecessarily without
inlining the whole thing.  Although the buffer in this case is long
enough to avoid truncation in ia64_dump_bs, the code depends on what I
think is C99 behavior of snprintf regarding return value during
truncation.  I tested with a short buffer and saw no evil effects
besides truncated lines.

I have not eliminated any backtrace levels, although the lack of
register output for the topmost level is a start up effect of the
implementation.

Signed-off-by: Bob Montgomery <bob.montgomery@hp.com>

--- linux-2.6.11.2/arch/ia64/kernel/process.c	2005-03-09 01:11:42.000000000 -0700
+++ linux-2.6.11.2-bobm/arch/ia64/kernel/process.c	2005-03-11 14:07:17.452448021 -0700
@@ -54,12 +54,42 @@ static cpumask_t cpu_idle_map;
 unsigned long boot_option_idle_override = 0;
 EXPORT_SYMBOL(boot_option_idle_override);
 
+void 
+ia64_dump_bs(struct unw_frame_info *info, unsigned long from, 
+	unsigned long to, char *buf, int bufsize)
+{
+	int ii, pos, nchars;
+	unsigned long val;
+	char nat;
+	unsigned long nregs = ia64_rse_num_regs((unsigned long *)from,
+			(unsigned long *)to);
+
+	if (nregs > 128)
+		/* something wrong */
+		return;
+
+	pos = nchars = 0;
+	/* avoid multiple printk's per line */
+	for (ii = 0; ii < nregs; ++ii) {
+		unw_get_gr(info, ii + 32, &val, &nat);
+		nchars += snprintf(buf + nchars, bufsize - nchars,
+			"%sr%-3d:%s%016lx",
+			(pos = 0) ? "    " : " ", ii + 32,
+			nat ? "*" : " ", val);
+		if (++pos = 3 || (ii = nregs - 1)) {
+			printk("%s\n", buf);
+			pos = nchars = 0;
+		}
+	}
+}
+
 void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)
 {
-	unsigned long ip, sp, bsp;
-	char buf[128];			/* don't make it so big that it overflows the stack! */
+	unsigned long ip, sp, bsp, lbsp;
+	char buf[128];	/* don't make it so big that it overflows the stack! */
 
+	lbsp = 0;
 	printk("\nCall Trace:\n");
 	do {
 		unw_get_ip(info, &ip);
@@ -73,6 +103,9 @@ ia64_do_show_stack (struct unw_frame_inf
 			 "                                sp=%016lx bsp=%016lx\n",
 			 ip, sp, bsp);
 		print_symbol(buf, ip);
+		if (lbsp > bsp)
+			ia64_dump_bs(info, bsp, lbsp, buf, sizeof(buf));
+		lbsp = bsp;
 	} while (unw_unwind(info) >= 0);
 }
 



