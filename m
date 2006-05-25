From: Andi Kleen <ak@suse.de>
Date: Thu, 25 May 2006 03:30:59 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <200605250531.00108.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com> <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, debian-ia64@lists.debian.org


> I'm a bit worried about this.  As I understand it, the Intel
> software emulator is not open-source.  There may be distros
> like Debian and customer environments where that's not a viable
> alternative.
> 
> If we remove CONFIG_IA32_SUPPORT, every ia64 box will require
> the Intel emulator (or QEMU or some other ill-defined solution)
> in order to run ia32 code, even though every processor in the
> field today supports ia32 in hardware.
> 
> It doesn't feel right to me to remove functionality from machines
> in the field and offer only a proprietary alternative.

You could just freeze the code down to "security fixes only". 
This means new system calls wouldn't need to be added and most programs
fallback if they don't see the latest and great syscalls anyways.
On the other hand it is usually not very hard to add new syscalls
and most of the other code is shared now anyways.

-Andi
