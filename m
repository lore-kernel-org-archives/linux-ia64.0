From: David Chinner <dgc@sgi.com>
Date: Wed, 19 Dec 2007 05:54:30 +0000
Subject: [ia64] BUG: sleeping in atomic
Message-Id: <20071219055430.GV4396912@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: lkml <linux-kernel@vger.kernel.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org

Just saw this again:

[ 5667.086055] BUG: sleeping function called from invalid context at kernel=
/fork.c:401
[ 5667.087314] in_atomic():1, irqs_disabled():0
[ 5667.088210]
[ 5667.088212] Call Trace:
[ 5667.089104]  [<a000000100015e00>] show_stack+0x80/0xa0
[ 5667.089106]                                 sp=E0000038f6507a00 bsp=E000=
0038f6500f48
[ 5667.116025]  [<a000000100015e50>] dump_stack+0x30/0x60
[ 5667.116028]                                 sp=E0000038f6507bd0 bsp=E000=
0038f6500f30
[ 5667.118317]  [<a0000001000af8a0>] __might_sleep+0x1e0/0x200
[ 5667.118320]                                 sp=E0000038f6507bd0 bsp=E000=
0038f6500f08
[ 5667.142316]  [<a0000001000c55a0>] mmput+0x20/0x220
[ 5667.142319]                                 sp=E0000038f6507bd0 bsp=E000=
0038f6500ee0
[ 5667.164201]  [<a000000100033ae0>] sys_ptrace+0x460/0x15c0
[ 5667.164203]                                 sp=E0000038f6507bd0 bsp=E000=
0038f6500dd0
[ 5667.175488]  [<a00000010000b4a0>] ia64_ret_from_syscall+0x0/0x20
[ 5667.175490]                                 sp=E0000038f6507e30 bsp=E000=
0038f6500dd0
[ 5667.199324]  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
[ 5667.199327]                                 sp=E0000038f6508000 bsp=E000=
0038f6500dd0
[ 5682.626704] BUG: sleeping function called from invalid context at kernel=
/fork.c:401

When stracing a process on 2.6.24-rc3 on ia64. commandline to reproduce:

# strace ls -l /mnt/scratch/test

ISTR reporting this some time ago (maybe 2.6.22?)....

Cheers,

Dave.
--=20
Dave Chinner
Principal Engineer
SGI Australian Software Group
