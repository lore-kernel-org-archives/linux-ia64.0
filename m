From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Thu, 18 Oct 2001 22:34:53 +0000
Subject: Re: [Linux-ia64] Kernel Resources & Allocation Order
Message-Id: <marc-linux-ia64-105590698805370@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805368@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805368@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Thu, 18 Oct 2001 15:24:08 -0500
"Donny Cooper" <dcooper@atcc.necsys.com> wrote:

> 
> Do kernel-parameters (such as, mem=X and maxcpus=N) have an allocation order according
> to the physical system layout, or
> even follow any order at all?

Current IA64 Linux implementation uses ACPI MADT order for limiting cpu
number and EFI_MEMMAP order for limiting memory.
The lowest-numberd cpus (except BSP) or the lowest-mapped memory range
is allocated.

> For example, if I boot with mem24M and maxcpus=2, will resources
> come from the low number DIMM and CPU slots.  Or is
> SMP completely random, with no guarantee which resources are allocated.

ACPI MADT numbering is dependent on firmware implementation (though
most platform choose the lowest numberd cpu to come first).
Which DIMM is the lowest memory is dependent on hardware
(memory-controller or chipset) and firmware (how to program
memory controller).

> I am aware that you cannot choose which
> resources to use, but the documentation I have found on this subject is unclear.

Rewriting the resource-limiting (maxcpu, maxmem) code, you can control
which part of cpu or memory will be used, but which part of cpu/mem
corresponds to which part of physical cpu/mem is different from
platform to platform.

Regards,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


