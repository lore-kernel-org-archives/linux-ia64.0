From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 09 Aug 2002 15:41:02 +0000
Subject: [Linux-ia64] Re: discontig-ia64 and acpi-numa patches
Message-Id: <marc-linux-ia64-105590701905927@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It turned out that some variables needed by SGI_SN were freed
too early in the previous release 20020807-split. Used the opportunity
to make the ACPI patch DISCONTIG-independent, the include files
asm/mmzone.h and asm/mmzone_dig_numa.h were moved from the acpi-numa
patch to the core patch. The updates are at
http://sf.net/project/showfiles.php?group_id=35660

Regards,
Erich


On Thursday 08 August 2002 18:40, Erich Focht wrote:
> Hi!
>
> This is a second attempt to split the discontig-ia64 patch. The result
> is on sourceforge at:
> http://sf.net/project/showfiles.php?group_id=35660&release_id=103977
>
> There are three patches for 2.4.18 + ia64-020722 :
>
> The main change: the previous core part was splitted, the ACPI
> initialization was changed into arch-dependent and -independent parts.
>
> 01_discontig-acpi-numa.diff : required, provides ACPI initialization
>                               of NUMA specific variables.
>
> 02_discontig-core.diff      : core part providing discontigmem
>                               functionality.
>
> 03_discontig-krel-krep.diff : optional part of discontigmem, provides
>                               kernel relocation and replication. Required
>                               on SGI SN.
>
> You can pply additionally one of the zonelist patches and the
> discontig-proc_info patch from the previous release.
>
> The ACPI part of the patch has been radically changed, it fits into the
> structure (arch-dependend + independent) proposed by Tak Kouchi. This
> part is functional and useful even without discontigmem. It basically
> gathers the NUMA related information and puts it into the structures
> node_memblk, node_cpuid, numa_slit. These contain, respectively, the
> affinity information of memory blocks, cpus and the locality information
> of the nodes. The code is quite arch-independent and could be used by
> other architectures which have ACPI SRAT/SLIT information.
>
> The patches are building blocks for the discontigmem needs on IA64:
> NEC Azusa/Asama, DIG64: required: acpi-numa + core,
>                         optional: krel-krep
> SGI SN : required: acpi + core + krel-krep
>
> For those involved into the DIG-discontigmem development: I've set
> CHUNKSIZE and CLUMPSIZE to be equal in mmzone_dig_numa.h. This avoids
> some pitfalls and we expect anyway contiguous physical memory here,
> so it doesn't matter.
>
> The patch is tested on 4 node Azusa. I left out the phoney SRAT/SLIT
> tables, they are now slightly more difficult to parse without extra code,
> so I'm afraid right now there's no way to test pseudo-NUMA on BigSur
> or Tiger.



