From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 06 Jan 2017 09:43:52 +0000
Subject: [PATCH v2 0/7] uapi: export all headers under uapi directories
Message-Id: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
In-Reply-To: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: mmarek@suse.com, linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.


Here is the v2 of this series. The first 5 patches are just cleanup: some
exported headers were still under a non-uapi directory.
The patch 6 was spotted by code review: there is no in-tree user of this
functionality.
The last patch remove the use of header-y. Now all files under an uapi
directory are exported.

asm is a bit special, most of architectures export asm/<arch>/include/uapi/asm
only, but there is two exceptions:
 - cris which exports arch/cris/include/uapi/arch-v[10|32];
 - tile which exports arch/tile/include/uapi/arch.
Because I don't know if the output of 'make headers_install_all' can be changed,
I introduce subdir-y in Kbuild file. The headers_install_all target copies all
asm/<arch>/include/uapi/asm to usr/include/asm-<arch> but
arch/cris/include/uapi/arch-v[10|32] and arch/tile/include/uapi/arch are not
prefixed (they are put asis in usr/include/). If it's acceptable to modify the
output of 'make headers_install_all' to export asm headers in
usr/include/asm-<arch>/asm, then I could remove this new subdir-y and exports
everything under arch/<arch>/include/uapi/.

Note also that exported files for asm are a mix of files listed by:
 - include/uapi/asm-generic/Kbuild.asm;
 - arch/x86/include/uapi/asm/Kbuild;
 - arch/x86/include/asm/Kbuild.
This complicates a lot the processing (arch/x86/include/asm/Kbuild is also
used by scripts/Makefile.asm-generic).

This series has been tested with a 'make headers_install' on x86 and a
'make headers_install_all'. I've checked the result of both commands.

This patch is built against linus tree. I don't know if it should be
made against antoher tree.

Comments are welcomed,
Nicolas
