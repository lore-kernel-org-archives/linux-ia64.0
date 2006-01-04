From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 04 Jan 2006 22:55:55 +0000
Subject: Re: [PATCH 2.6.15 1/2] ia64: use i386 dmi_scan.c
Message-Id: <1136415355.7443.1.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com>
In-Reply-To: <20060104221627.GA26064@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Mer, 2006-01-04 at 16:16 -0600, Matt Domsch wrote:
> Andi Kleen has a patch in his x86_64 tree which enables the use of
> i386 dmi_scan.c on x86_64.  dmi_scan.c functions are being used by the
> drivers/char/ipmi/ipmi_si_intf.c driver for autodetecting the ports or
> memory spaces where the IPMI controllers may be found.
> 
> This patch adds equivalent changes for ia64 as to what is in the
> x86_64 tree.

I was under the impression that the correct way to find the DMI tables
on IA64 was by the EFI[ng ;)] firmware interface

