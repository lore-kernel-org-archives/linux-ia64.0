From: "Sy, Dely L" <dely.l.sy@intel.com>
Date: Thu, 04 Mar 2004 18:30:10 +0000
Subject: RE: Fix PCIE and SHPC hotplug drivers for ia64
Message-Id: <9CB758BBEE58754F8F33234D75B9F4B0017F9A24@orsmsx410.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek720wmgw.fsf@sykes.suse.de>
In-Reply-To: <jek720wmgw.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, March 04, 2004 10:04 AM, Greg KH wrote:
> On Thu, Mar 04, 2004 at 06:28:31PM +0100, Andreas Schwab wrote:
> > This patch fixes the PCIE and SHPC hotplug driver for ia64. The
function
> > pcibios_set_irq_routing only exists on x86, and acpi_bridges_head
may be
> > NULL, so don't crash.

> This looks sane to me, Dely?

Thanks for the fix.  It looks good to me.

Thanks,
Dely


