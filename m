From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Apr 2003 20:38:37 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 zx1 updates
Message-Id: <marc-linux-ia64-105590723705404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705393@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Alex> This first patch includes a forward port of the
  Alex> 2.4 sba_iommu, removes the fake PCI components and reorganizes
  Alex> some of the support routines.  Patch is against 2.5.64 +
  Alex> 030307.

Applied with some small changes (spell HP as "Hewlett-Packard",
whitespace fixups, add #ifdef to acpi-exit.h and include of
<linux/types.h>, correct filename in acpi-ext.c).

Thanks,

	--david

