From: Greg KH <greg@kroah.com>
Date: Wed, 04 Oct 2006 22:56:49 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 1/3] - Altix: Add initial ACPI IO support
Message-Id: <20061004225649.GB14395@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061004214925.3193.26724.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20061004214925.3193.26724.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org

On Wed, Oct 04, 2006 at 04:49:25PM -0500, John Keller wrote:
> First phase in introducing ACPI support to SN.
> In this phase, when running with an ACPI capable PROM,
> the DSDT will define the root busses and all SN nodes
> (SGIHUB, SGITIO). An ACPI bus driver will be registered
> for the node devices, with the acpi_pci_root_driver being
> used for the root busses. An ACPI vendor descriptor is
> now used to pass platform specific information for both
> nodes and busses, eliminating the need for the current
> SAL calls. Also, with ACPI support, SN fixup code is no longer
> needed to initiate the PCI bus scans, as the acpi_pci_root_driver
> does that.

How do these three patches differ from the ones I added to my tree
yesterday?

> Resend #2 - resync with TOT

"TOT"?

thanks,

greg k-h
