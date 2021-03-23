From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 23 Mar 2021 16:28:07 +0000
Subject: Re: vmlinux link failure on ia64 with zstd
Message-Id: <bf540b24-6111-6523-17f6-aac21349fd8b@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <f0a93b2d435252b3878ce821142677754f5e434c.camel@decadent.org.uk>
In-Reply-To: <f0a93b2d435252b3878ce821142677754f5e434c.camel@decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ben!

On 9/13/20 9:51 PM, Ben Hutchings wrote:
> Enabling CONFIG_RD_ZSTD (which is enabled by default) resulted in a
> link failure on ia64:
> 
> + ld -r -o vmlinux.o --whole-archive arch/ia64/kernel/head.o init/built-in.a usr/built-in.a arch/ia64/kernel/built-in.a arch/ia64/mm/built-in.a kernel/built-in.a certs/built-in.a mm/built-in.a fs/built-in.a ipc/built-in.a security/built-in.a crypto/built-in.a block/built-in.a lib/built-in.a arch/ia64/lib/built-in.a lib/lib.a arch/ia64/lib/lib.a drivers/built-in.a sound/built-in.a net/built-in.a virt/built-in.a arch/ia64/pci/built-in.a arch/ia64/hp/common/built-in.a --no-whole-archive --start-group --end-group
> ld: lib/zstd/entropy_common.o: linking constant-gp files with non-constant-gp files
> ld: failed to merge target specific data of file lib/zstd/entropy_common.o
> ld: lib/zstd/fse_decompress.o: linking constant-gp files with non-constant-gp files
> ld: failed to merge target specific data of file lib/zstd/fse_decompress.o
> ld: lib/zstd/zstd_common.o: linking constant-gp files with non-constant-gp files
> ld: failed to merge target specific data of file lib/zstd/zstd_common.o

It was suggested on IRC (#debian-ports) that we need to pass "-mconstant-gp" to GCC at
the right places and it seems this issue existed before in the past [1]. Fix seems
trivial.

Adrian

> [1] https://marc.info/?l=linux-kbuild&m3643269731499&w=2

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
