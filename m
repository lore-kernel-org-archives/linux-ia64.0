From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 10 Jul 2006 03:29:25 +0000
Subject: Re: [PATCH] remove empty node at boot time
Message-Id: <20060710122925.759c368b.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060601200436.6bf7c4e5.kamezawa.hiroyu@jp.fujitsu.com>
	<200607071726.31646.bjorn.helgaas@hp.com>
	<20060710093418.be084931.kamezawa.hiroyu@jp.fujitsu.com>
	<200607092038.41053.bjorn.helgaas@hp.com>
In-Reply-To: <200607092038.41053.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, akpm@osdl.org

On Sun, 9 Jul 2006 20:38:40 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> Yes.  Here's the relevant part of the call tree:
> 
> setup_arch
>   acpi_numa_init
>     acpi_numa_arch_fixup
>       acpi_online_node_fixup (test available_cpus)
>   ... 
>   acpi_boot_init
>     acpi_table_parse_madt(..., acpi_parse_lsapic, ...)
>       acpi_parse_lsapic (increment available_cpus)
> 
> Note that we test available_cpus in acpi_online_node_fixup()
> before we increment it in acpi_parse_lsapic(), so the inner
> loop is never executed.

Hmm...okay, I misunderstood the boot path..
To work with my remove-empty-node patch, parsing lsapic should be done
before SRAT. 
I'd like to fix this. BTW, can we move parsing MADT before SRAT ?

-Kame


