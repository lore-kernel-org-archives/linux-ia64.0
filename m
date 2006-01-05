From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 05 Jan 2006 17:37:40 +0000
Subject: Re: [PATCH 2.6.15 1/2] ia64: use i386 dmi_scan.c
Message-Id: <20060105173740.GA20650@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <1136414164.6198.36.camel@localhost.localdomain> <20060104232944.GA32250@lists.us.dell.com> <200601050941.15915.bjorn.helgaas@hp.com>
In-Reply-To: <200601050941.15915.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Alex Williamson <alex.williamson@hp.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Thu, Jan 05, 2006 at 09:41:15AM -0700, Bjorn Helgaas wrote:
> The DMI scan looks like it's done in try_init_smbios().  But
> try_init_acpi() is done first.  Since every ia64 machine has
> ACPI, I would think try_init_acpi() should be sufficient.
> 
> Or do you have a machine that doesn't supply the SPMI
> table used by try_init_acpi()?

This system (Dell PowerEdge 7250, very very similar to an Intel 4-way
Itanium2 server) doesn't have an SPMI table, but it does have the IPMI
information in the SMBIOS table.

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
