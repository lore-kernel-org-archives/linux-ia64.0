From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 12 Sep 2005 15:17:16 +0000
Subject: Re: [RFC] /proc/efi_memmap
Message-Id: <200509120917.16531.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
In-Reply-To: <200509092346.j89NkDdo001318@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 09 September 2005 5:46 pm, Luck, Tony wrote:
> 1) Is /proc/efi_memmap a good name?

There's already a /sys/firmware/efi/;  maybe it should go under
there somewhere?

This functionality is arch-independent, so if you do it, you might
as well put it somewhere like drivers/firmware/efi/, and make it
work for x86 at the same time.
