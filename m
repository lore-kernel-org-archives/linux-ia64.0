From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Wed, 22 Sep 2004 16:59:29 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <20040922095929.A2631@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920093532.D14208@unix-os.sc.intel.com> <20040922131757.509ba88d.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040922131757.509ba88d.tokunaga.keiich@jp.fujitsu.com>; from tokunaga.keiich@jp.fujitsu.com on Wed, Sep 22, 2004 at 01:17:57PM +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> In acpi_eject_store(), eject_operation() is called regardless of the
> result of acpi_bus_trim().  I think that eject_operation() should be
> called only when acpi_bus_trim() returns success.  Otherwise, a
> device stil being online will be ejected forcibly.
> 
> Two steps might be needed to do this.
> 
>     1. Modify acpi_bus_trim() to return success only when all the
>         acpi_bus_remove() are done successfully.
>     2. Modify acpi_eject_store() to see the result and call eject_operation()
>         only when the result is success.
Hi Kei-san,
Your idea and the patch both looks good to me. 
Thanks for eye balling the code and detecting the corner cases like this.
> 
> Here is a patch just to show what I have in mind.  It is still based on
> the recursion, so please fix it as appropriate ;)

I will merge this with my non-recursion version of the patch and post it ASAP.

thanks,
Anil
