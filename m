From: Keith Owens <kaos@sgi.com>
Date: Thu, 05 Aug 2004 12:52:23 +0000
Subject: Re: [PATCH&RFC 2/2] OS_MCA Recovery from poisoned memory read
Message-Id: <5470.1091710343@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <41121484.40804@jp.fujitsu.com>
In-Reply-To: <41121484.40804@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks good.  Some minor niggles, without actually testing the code.

On Thu, 05 Aug 2004 20:05:40 +0900, 
Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:
>+/*
>+ * mca_page_isolate
>+ *
>+ *	isolate a poisoned page	in order not to use it later
>+ * 
>+ *  Input	: paddr (poisoned memory location)
>+ *  Output	: isolate_status (isolation was succeeded or failed.)
>+ */

Standard kernel doc headers would be better.  See
Documentation/kernel-doc-nano-HOWTO.txt.

+       typedef struct ia64_fptr {
+               unsigned long fp;
+               unsigned long gp;
+       } ia64_fptr_t;

Duplicated here and in arch/ia64/kernel/mca.c.  ia64_fptr should be in
a common header.

+                       /* change resume address to bottom half */
+                       pmsa->pmsa_iip = mca_hdlr_bh->fp;
+                       pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
+                       /* set cpl with kernel mode */
+                       psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
+                       psr2->cpl = 0;

Also psr2->ri = 0; to ensure that pmsa_iip resumes at the start of the
bottom half.

>+#ifdef MODULE

No need to wrap in #ifdef MODULE, these commands also work when the
code is built in.

>+MODULE_PARM(sal_rec_max, "i");

Use module_param() plus MODULE_PARM_DESC() instead of MODULE_PARM().
module_param() lets you specify the value at boot time for built in
code, MODULE_PARM() does not.

+static isolate_status_t
+mca_page_isolate(unsigned long paddr)
+{
+       int i;
+       struct page *p;
+
+       /* whether physical address is valid or not */
+       if ( !ia64_phys_addr_valid(paddr) )  

The calls to mca_page_isolate() are racy.  That code is running in
normal kernel context after exiting from the MCA handler.  Other cpus
could be modifying the page tables at the same time, there could even
be two cpus running mca_handler_bh() at the same time for the same
page.

