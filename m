From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 09 Sep 2004 01:07:57 +0000
Subject: Re: [PATCH] general config option cleanup
Message-Id: <200409081807.57695.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409081447.38703.jbarnes@engr.sgi.com>
In-Reply-To: <200409081447.38703.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 8, 2004 6:02 pm, Ian Wienand wrote:
> On Wed, Sep 08, 2004 at 02:47:38PM -0700, Jesse Barnes wrote:
> > As threatened, here's a patch that unifies the ia64 memory init and
> > memmap codepaths by unconditionalizing the CONFIG_VIRTUAL_MEM_MAP code
> > and making CONFIG_DISCONTIGMEM required.  It also allows building with
> > CONFIG_SMP=n and/or CONFIG_NUMA=n.
>
> Two related things I noticed.  Firstly, shouldn't the ACPI_NUMA option
> be linked to NUMA (i.e. if you select one, Kconfig selects the other)?
>
> Secondly, trying to build with CONFIG_NUMA and CONFIG_ACPI_NUMA off
> gave errors like
>
> arch/ia64/mm/built-in.o(.init.text+0x3c0): In function `early_nr_cpus_node':
> : undefined reference to `node_cpuid'
>
> arch/ia64/mm/built-in.o(.init.text+0xf71): In function 
`call_pernode_memory':
> : undefined reference to `num_node_memblks'
>
> How about moving the definions in question either outside of #ifdef
> CONFIG_ACPI_NUMA in apci.c or adding them to discontig.c (as below).

Hmm... yeah, I knew that would break.  The thing is, ia64 NUMA machines all 
provide ACPI NUMA tables to describe their NUMAness, so I figured it was 
pointless to try and break that up, but I don't really mind either way.

Jesse
