From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jul 2007 22:32:13 +0000
Subject: RE: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <617E1C2C70743745A92448908E030B2A0209BADF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070727074413.GA11424@uranus.ravnborg.org>
References: <20070726210141.GA7266@uranus.ravnborg.org>
In-Reply-To: <20070726210141.GA7266@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

-		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
-					 * NR_CPUS + KERNEL_STACK_SIZE);
+		mca_data = mca_bootmem(NR_CPUS + KERNEL_STACK_SIZE);

Oops.  You moved the multiply by sizeof(struct ia64_mca_cpu) up into
the mca_bootmem() function to make it very specific to this use. But
mutiply has higher precedence than addition.

-Tony
