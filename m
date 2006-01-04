From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 04 Jan 2006 22:36:03 +0000
Subject: Re: [PATCH 2.6.15 1/2] ia64: use i386 dmi_scan.c
Message-Id: <1136414164.6198.36.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com>
In-Reply-To: <20060104221627.GA26064@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Wed, 2006-01-04 at 16:16 -0600, Matt Domsch wrote:
> Andi Kleen has a patch in his x86_64 tree which enables the use of
> i386 dmi_scan.c on x86_64.  dmi_scan.c functions are being used by the
> drivers/char/ipmi/ipmi_si_intf.c driver for autodetecting the ports or
> memory spaces where the IPMI controllers may be found.

   Can't this be done via ACPI/EFI?  I'm really opposed to adding
anything to ia64 that blindly picks memory ranges and starts scanning
for magic legacy tables.  If nothing else, this can be found via
efi.smbios.  Thanks,

	Alex

