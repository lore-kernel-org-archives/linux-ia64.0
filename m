From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 06:40:21 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <16884.38997.209621.947323@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Jan 2005 10:48:46 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> +.mem.offset 0,0; (p6) st8 [r2]=r8		// store return value in slot for r8
  Ken> +.mem.offset 8,0; (p6) st8 [r3]=r0		// clear error indication in slot for r10

Without the .mem.offset, please?

	--david
