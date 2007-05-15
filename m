From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 May 2007 18:31:17 +0000
Subject: RE: [PATCH] ia64: optimize pagefaults a little
Message-Id: <617E1C2C70743745A92448908E030B2A01785F17@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070512155724.GB8412@lst.de>
In-Reply-To: <20070512155724.GB8412@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


+	if (!user_mode(regs)) {
+		/* kprobe_running() needs smp_processor_id() */
+		preempt_disable();
+		if (kprobe_running() && kprobes_fault_handler(regs, trap))
+			ret = 1
+		preempt_enable();
+	}

Missing a ';' on the "ret = 1" line.
 
 	DIE_FAULT,
 	DIE_OOPS,
-	DIE_PAGE_FAULT,
 	DIE_MACHINE_HALT,
 	DIE_MACHINE_RESTART,
 	DIE_MCA_MONARCH_ENTER,

You've deleted the DIE_PAGE_FAULT identifier, but there
is still code in kprobes.c:kprobe_exceptions_notify() that
uses it.  Presumably you meant to delete the whole

    case DIE_PAGE_FAULT:

clause there too?

-Tony
