From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Jan 2002 18:45:50 +0000
Subject: [Linux-ia64] heads-up: don't treat __FUNCTION__ as a constant
Message-Id: <marc-linux-ia64-105590698805912@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A heads-up about a change that's forthcoming in gcc3.1: the
__FUNCTION__ macro should no longer be treated as returning a constant
string literal.  gcc3.1 will still allow it, but issue an ugly warning
message.  In later releases, the feature will go away completely.

The reason for deprecating this feature is that ANSI C pretty much
disallows it: string literal concatenation is required to be done in a
phase *before* the name of the current function is known.  The
solution is to change something of the form:

	printk(__FUNCTION__": you lose\n");

into something like this:

	printk("%s: you lose\n", __FUNCTION__);

I did a quick grep over the ia64 code and found the following files
are using __FUNCTION__:

arch/ia64/kernel/efi.c
arch/ia64/kernel/palinfo.c
arch/ia64/kernel/perfmon.c
arch/ia64/kernel/smp.c
arch/ia64/kernel/unaligned.c
arch/ia64/sn/io/pci.c
arch/ia64/sn/io/pci_bus_cvlink.c
arch/ia64/sn/io/pciba.c
arch/ia64/sn/io/pciio.c
arch/ia64/sn/io/sn1/pcibr.c
arch/ia64/sn/io/sn2/ml_SN_intr.c
arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c

It might be a good idea to clean these up as you're working on it.
It's not urgent, of course, but I wanted to make you aware of this
issue so we can at least avoid writing new code using this construct.

Thanks,

	--david

