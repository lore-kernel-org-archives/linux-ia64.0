From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 19 Jan 2006 14:19:42 +0000
Subject: RE: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB00C26DFB1@fmsmsx406.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060106172140.GB19605@lists.us.dell.com>
In-Reply-To: <20060106172140.GB19605@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

Andi Kleen <> wrote:
> Regarding physical vs virtual efi.smbios -- it sounds nasty to have
> such a difference in the EFI support for different architectures.
> Matthew, do you have a suggestion how this can be unified?

Yes, Bjorn and I talked about this offline.  I had a patch out there
a while back that converged this specifically for the acpi addresses.  
We should be able to convert them all to just one type.  

matt
