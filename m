From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Mar 2007 20:24:27 +0000
Subject: RE: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <617E1C2C70743745A92448908E030B2A01483822@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+smp_flush_tlb_cpumask (cpumask_t xcpumask)
+{
+	unsigned short counts[NR_CPUS];

Even as a "short" ... that is still a lot of stack.  Possibly
a new place to fail when NR_CPUS gets bumped up again?

+#define IA64_IPI_LOCAL_TLB_FLUSH	0xfc	/* SMP reschedule */
 #define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */

Cut & pasted the comment when duping this line?


-Tony
