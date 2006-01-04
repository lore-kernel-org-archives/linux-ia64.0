From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 04 Jan 2006 23:29:44 +0000
Subject: Re: [PATCH 2.6.15 1/2] ia64: use i386 dmi_scan.c
Message-Id: <20060104232944.GA32250@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <1136414164.6198.36.camel@localhost.localdomain>
In-Reply-To: <1136414164.6198.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Wed, Jan 04, 2006 at 03:36:03PM -0700, Alex Williamson wrote:
> On Wed, 2006-01-04 at 16:16 -0600, Matt Domsch wrote:
> > Andi Kleen has a patch in his x86_64 tree which enables the use of
> > i386 dmi_scan.c on x86_64.  dmi_scan.c functions are being used by the
> > drivers/char/ipmi/ipmi_si_intf.c driver for autodetecting the ports or
> > memory spaces where the IPMI controllers may be found.
> 
>    Can't this be done via ACPI/EFI?  I'm really opposed to adding
> anything to ia64 that blindly picks memory ranges and starts scanning
> for magic legacy tables.  If nothing else, this can be found via
> efi.smbios.  Thanks,

I'll redo this to use efi.smbios.  Thanks for the tip.

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
