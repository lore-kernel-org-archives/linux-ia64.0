From: Greg KH <greg@kroah.com>
Date: Thu, 04 Mar 2004 18:03:39 +0000
Subject: Re: Fix PCIE and SHPC hotplug drivers for ia64
Message-Id: <20040304180339.GA11753@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek720wmgw.fsf@sykes.suse.de>
In-Reply-To: <jek720wmgw.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 04, 2004 at 06:28:31PM +0100, Andreas Schwab wrote:
> This patch fixes the PCIE and SHPC hotplug driver for ia64.  The function
> pcibios_set_irq_routing only exists on x86, and acpi_bridges_head may be
> NULL, so don't crash.

This looks sane to me, Dely?

thanks,

greg k-h
