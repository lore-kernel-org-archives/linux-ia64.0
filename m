From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 10 Jul 2006 02:38:40 +0000
Subject: Re: [PATCH] remove empty node at boot time
Message-Id: <200607092038.41053.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060601200436.6bf7c4e5.kamezawa.hiroyu@jp.fujitsu.com> <200607071726.31646.bjorn.helgaas@hp.com> <20060710093418.be084931.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060710093418.be084931.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, akpm@osdl.org

On Sunday 09 July 2006 18:34, KAMEZAWA Hiroyuki wrote:
> Then, your box has 
> node 0 : cpu x 4, small memory
> node 1 : cpu x 4, small memory
> node 2 : big memory.

Yes.

> if above node 0 and node 1 disappears, it looks there are some bugs in
> cpu detection.

Yes.  Here's the relevant part of the call tree:

setup_arch
  acpi_numa_init
    acpi_numa_arch_fixup
      acpi_online_node_fixup (test available_cpus)
  ... 
  acpi_boot_init
    acpi_table_parse_madt(..., acpi_parse_lsapic, ...)
      acpi_parse_lsapic (increment available_cpus)

Note that we test available_cpus in acpi_online_node_fixup()
before we increment it in acpi_parse_lsapic(), so the inner
loop is never executed.
