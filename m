From: Matthew Wilcox <willy@debian.org>
Date: Mon, 03 Jun 2002 17:35:42 +0000
Subject: Re: [Linux-ia64] Integer to Pointer Cast Warnings when Building 2.4.17
Message-Id: <marc-linux-ia64-105590701905633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905629@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905629@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 03, 2002 at 10:23:09AM -0700, David Mosberger wrote:
> These come from the ACPI subsystem.  They annoy me, too, but it's up
> to the ACPI folks to fix them.  It's possible they're already fixed in
> the latest ACPI drops.

When compiling my current tree which includes ACPI CA 20020517, the only
warning I get is:

pci_irq.c: In function `acpi_pci_irq_enable':
pci_irq.c:304: warning: unused variable `irq_mask'

which is a fairly benign type of warning.

-- 
Revolutions do not require corporate support.

