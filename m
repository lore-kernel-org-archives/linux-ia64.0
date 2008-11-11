From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Nov 2008 22:56:23 +0000
Subject: RE: unaligned access messages
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C2E22F6@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811071956.mA7JuXJd015345@agluck-lia64.sc.intel.com>
In-Reply-To: <200811071956.mA7JuXJd015345@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> $ dmesg | grep unaligned
> init(1): unaligned access to 0x600000000008b0bb, ip=0x40000000000e3581

I've been looking at this some more and found out more
details on what is happening here.

These "init" messages actually come from "nash" on the
initrd.  The specific code in nash is probe_fat() (from
libblkid) which is trying to determine if a partition
contains a fat/vfat filesystem.  The code here accesses
unaligned 2-byte objects (the ms_sectors field of
msdos_super_block, and vs_sectors/vs_dir_entries fields
of vfat_super_block structures).

The reason these generate unaligned traps in some kernels
but not others is the the PSR.ac bit is set differently
in the different kernels ... apparently because there is
no explicit initialization of it (that I can see[1]) so it
inherits a value from some random place.

Why this scheduler patch consistently results in PSR.ac
being set is still a mystery to me ... but we should pick
some spot to initialize it.

-Tony

[1] The only initialization I can find is in the ia32
exec path in binfmt_elf32.c ... which is obviously of
little use for nash, which is a 64-bit native ia64 binary.
