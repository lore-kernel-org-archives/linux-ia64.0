From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 03 Apr 2003 20:08:46 +0000
Subject: Re: [Linux-ia64] module support for 2.5 kernel
Message-Id: <marc-linux-ia64-105590723705402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705330@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705330@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Xavier> Hi David,

  Xavier> Thanks for providing this important functionality.

  Xavier> We found the following (minor :-) problems:

  Xavier> 1) missing module.o in arch/ia64/kernel/Makefile.

Oops, I must have dropped that by accident.  Sorry.

  Xavier> 2) using CONFIG_MODVERSIONS, the per-cpu-check.awk script fails with
  Xavier> __crc_xxx symbols:

  Xavier> 000000004d13d7e9 A __crc_page_states__per_cpu not in per-cpu section
  Xavier> 00000000b4f8f003 A __crc_cpu_info__per_cpu not in per-cpu section
  Xavier> make: *** [vmlinux] Error 1

  Xavier> Just changing the script to ignore them fixes the problem.

Yes, the warning is bogus.  Your fix looks fine to me.

  Xavier> 3) with CONFIG_NUMA set, there are undefined symbols building modules:

  Xavier> scripts/modpost vmlinux drivers/md/dm-mod.o drivers/net/e1000/e1000.o drivers/net/eepro100.o drivers/md/md.o drivers/net/mii.o fs/xfs/xfs.o
  Xavier> *** Warning: "cpu_info__per_cpu" [fs/xfs/xfs.ko] undefined!
  Xavier> *** Warning: "cpu_info__per_cpu" [drivers/md/md.ko] undefined!
  Xavier> *** Warning: "cpu_to_node_map" [drivers/md/md.ko] undefined!

  Xavier> exporting them in ia64_ksyms.c fixes the problem.

  Xavier> Hereafter a possible patch that applies on top of yours:

OK, I don't know why cpu_info__per_cpu wasn't exported for NUMA.  I
suspect it had something to do with using node-local memory.  If
someone sees a problem with exporting this symbol, please speak up.

	--david

