From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 07 Apr 2004 15:09:12 +0000
Subject: Re: [PATCH] ISA stubs for ia64
Message-Id: <200404070909.12603.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404061630.20264.bjorn.helgaas@hp.com>
In-Reply-To: <200404061630.20264.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 06 April 2004 5:18 pm, David Mosberger wrote:
> I don't like this patch at all.  The #defines to
> unsupported_isa_dma_interface() turn compile-time errors into
> potential runtime errors.  With a properly abstracted interface, the
> ISA-compatibility-macros should not lead to any code in ISA-free
> systems (and hence there would be no possibility of runtime errors).

True.  I actually started by modifying drivers to use CONFIG_ISA to
determine whether to use ISA interfaces, but (a) that leads to a lot
of changes, most of which I can't test and have the potential to break
other arches, and (b) somebody suggested that ISA is sort of a special
case because it hasn't been converted to the driver model.

But I certainly agree that it would be a lot cleaner.
