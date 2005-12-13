From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Dec 2005 17:24:13 +0000
Subject: RE: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0531DC38@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think this is too complicated.  Initcall ordering is fragile as it
> is. 
...

> Can you use the existing machine vector infrastructure to solve this
> problem?  For example, what if you added a "platform_device_setup()"
> hook that is a no-op on most platforms, but maps to sn_device_setup()
> in the SN2 machine vector?  platform_device_setup() would itself be
> called as a device_initcall().

This solution would move all the sn2 initializaions into the
device_initcall sequence.  Which might cause some ordering
problems.  E.g. sn_pci_init() is a "subsys_initcall" ... and I
expect that it really needs to happen before any of the
device_initcalls.

So there would have to be a sn_* version for potentially each of
the 7 existing levels of initcall to keep the ordering.

-Tony
