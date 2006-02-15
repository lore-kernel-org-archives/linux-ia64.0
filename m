From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Feb 2006 19:40:18 +0000
Subject: RE: missing entries in fsys.S
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05B87560@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060215143359.GB14787@frankl.hpl.hp.com>
In-Reply-To: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+	// guard against failures to increase NR_syscalls
+	.org fsyscall_table + 8*NR_syscalls

Is this redundant ... with the .space directive I don't think
that this can ever trip ... can it?

-Tony
