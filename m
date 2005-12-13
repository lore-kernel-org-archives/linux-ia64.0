From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Dec 2005 17:47:14 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <200512131047.14264.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 13 December 2005 10:24 am, Luck, Tony wrote:
> > I think this is too complicated.  Initcall ordering is fragile as it
> > is. 
> ...
> 
> > Can you use the existing machine vector infrastructure to solve this
> > problem?  For example, what if you added a "platform_device_setup()"
> > hook that is a no-op on most platforms, but maps to sn_device_setup()
> > in the SN2 machine vector?  platform_device_setup() would itself be
> > called as a device_initcall().
> 
> This solution would move all the sn2 initializaions into the
> device_initcall sequence.  Which might cause some ordering
> problems.  E.g. sn_pci_init() is a "subsys_initcall" ... and I
> expect that it really needs to happen before any of the
> device_initcalls.

Well, sure.  device_setup() was just an example.  I expect they'd
want to add more (subsys, etc).  I doubt that all the levels would
be needed, but even if they were, I'd prefer it over sprinkling
"ia64_platform_is" everywhere.
