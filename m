From: Andi Kleen <ak@suse.de>
Date: Tue, 09 Mar 2004 23:54:28 +0000
Subject: Re: [PATCH] clean up some ACPI IRQ conversions
Message-Id: <20040309235428.GA25936@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
In-Reply-To: <200403091619.04333.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

> These changes (all together, not individually) have been built and
> booted on ia64 and built for i386.

The x86-64 changes look fine to me. I suppose you will submit them directly?
Before you do that I would appreciate it if you could at least compile
check x86-64 and fix any compile errors that may have been introduced.

Cross compilers for that can be found in
ftp://ftp.suse.com/pub/suse/x86_64/supplementary/CrossTools/8.1-i386
(or ftp://ftp.gwdg.de:/pub/suse/... if suse.com is too slow) 

-Andi
