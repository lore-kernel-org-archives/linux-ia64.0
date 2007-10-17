From: "Tony Luck" <tony.luck@intel.com>
Date: Wed, 17 Oct 2007 17:19:18 +0000
Subject: Re: [PATCH 0/3] vmcoreinfo support for dump filtering
Message-Id: <12c511ca0710171019t35cb1670k9e1bdcfb3bf99793@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822210838oomichi@mail.jp.nec.com>
In-Reply-To: <20070822210838oomichi@mail.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ken'ichi Ohmichi <oomichi@mxs.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, kexec-ml <kexec@lists.infradead.org>, Neil Horman <nhorman@redhat.com>, Vivek Goyal <vgoyal@in.ibm.com>, Bernhard Walle <bwalle@suse.de>, Don Zickus <dzickus@redhat.com>, Dan Aloni <da-x@monatomic.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> This patch set frees the restriction that makedumpfile users should
> install a vmlinux file (including the debugging information) into
> each system.

This patch went from Andrew to Linus last night, and looks at first
glance to be the reason why the ia64 build is broken this morning
when using the arch/ia64/configs/tiger_defconfig configuration.

Here are the error messages:
arch/ia64/kernel/machine_kexec.c: In function `arch_crash_save_vmcoreinfo':
arch/ia64/kernel/machine_kexec.c:131: error: `pgdat_list' undeclared
(first use in this function)
arch/ia64/kernel/machine_kexec.c:131: error: (Each undeclared
identifier is reported only once
arch/ia64/kernel/machine_kexec.c:131: error: for each function it appears in.)
arch/ia64/kernel/machine_kexec.c:134: error: `node_memblk' undeclared
(first use in this function)
arch/ia64/kernel/machine_kexec.c:135: error: `NR_NODE_MEMBLKS'
undeclared (first use in this function)
arch/ia64/kernel/machine_kexec.c:136: error: invalid application of
`sizeof' to incomplete type `node_memblk_s'
arch/ia64/kernel/machine_kexec.c:137: error: dereferencing pointer to
incomplete type
arch/ia64/kernel/machine_kexec.c:138: error: dereferencing pointer to
incomplete type
make[1]: *** [arch/ia64/kernel/machine_kexec.o] Error 1

-Tony
