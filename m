From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 19 Jun 2003 20:48:33 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105605585016024@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 19, 2003 at 10:36:34AM -0700, David Mosberger wrote:
> machines (assuming the SGI guys can get the latest 2.5 bits to boot,
> of course).  This should tell us whether the bug is really in the I/O

Almost there, I promise!  Once the discontig stuff is in, the only piece
left will be PCI initialization.  We used to drive it via pcibios_init
and platform_pci_fixup, but now that the ia64 PCI layer is totally ACPI
driven, I have to figure out something else.

Thanks,
Jesse
