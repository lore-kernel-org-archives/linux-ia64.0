From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 02 Aug 2002 00:19:48 +0000
Subject: [Linux-ia64] discontig patch split
Message-Id: <marc-linux-ia64-105590701905880@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

This is an attempt to split up the DISCONTIGMEM patch for IA64
into smaller pieces, as discussed in the Atlas meeting. The parts are:

1 : discontig-core-2.4.18-0722.diff  : core part, contains multiple
    bootmem and pg_data, acpi setup routines for SRAT/SLIT
    tables. Almost entirely architecture dependent.

2 : discontig-kreloc-krep-2.4.18-0722.diff : relocatable kernel
    and kernel replication. Absolutely needed for SGI-IA64.

3a: discontig-zonelist-v1-2.4.18.diff : original IA64 code for
    solving the problem of kswapd starting to swap if one node
    is low on memory even if the others aren't.

3b: discontig-zonelist-v2-2.4.18.diff : alternative to 3a, same
    concept but using architecture-independent changes. This is
    basically the patch in Andrea's kernels.

3c: discontig-multi_kswapd-2.4.18.diff : alternative to 3a and 3b,
    doesn't extend the zonelists, instead implements per node
    kswapd and wakes them up depending on the setting of
    the constant NUMA_RATIO and the balance of the nodes. This
    goes back to Sam Ortiz' proposal discussed 6 months ago.

4:  discontig-proc_info-2.4.18.diff : show info on memory usage
    in /proc/discontig. Architecture independent.

The patches can be seen as building blocks. For NEC Azusa
and Asama the minimum requirement is patch 1, for SGI SN one
should take additionally patch 2.

The files are on sourceforge:
http://sf.net/project/showfiles.php?group_id=35660&release_id=95846

The inclusion into the IA64 port of patch #1 as a common part needed
for discontigmem on Itanium platforms would be desireable...

Best regards,
Erich


