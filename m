From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Mar 2006 18:23:41 +0000
Subject: RE: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061AA7F3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I applied this patch and compiled using gcc-4.1.0-3.
> 
> I now see hundreds of warnings like:
> 
> WARNING: drivers/atm/he.o - Section mismatch: reference to 
> .init.text:he_start from .text after 'he_init_one' (at offset 0x81a2)
> WARNING: drivers/block/cpqarray.o - Section mismatch: reference to 
> .init.text:cpqarray_init_one from .data.rel.local between 
> 'cpqarray_pci_driver' (at offset 0x20) and 'smart1_access'

Just tried with vanilla gcc 4.1.0, and I don't see these
warnings.

BTW, these messages presumably come from scripts/mod/modpost.c

-Tony
