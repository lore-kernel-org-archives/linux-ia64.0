From: Andrew Morton <akpm@osdl.org>
Date: Thu, 03 Mar 2005 11:37:04 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <20050303033704.6fb77a34.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
In-Reply-To: <16923.193.128608.607599@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

jes@trained-monkey.org (Jes Sorensen) wrote:
>
> This patch introduces ia64 specific read/write handlers for /dev/mem
>  access which is needed to avoid uncached pages to be accessed through
>  the cached kernel window which can lead to random corruption.

This patch causes hiccups on my ia32e box.

linux:/home/akpm#  /usr/sbin/hwscan --isapnp                       
zsh: 7528 segmentation fault  /usr/sbin/hwscan --isapnp
linux:/home/akpm#  /usr/sbin/hwscan --pci   
zsh: 7529 segmentation fault  /usr/sbin/hwscan --pci
linux:/home/akpm#  /usr/sbin/hwscan --block
zsh: 7530 segmentation fault  /usr/sbin/hwscan --block
linux:/home/akpm#  /usr/sbin/hwscan --floppy
zsh: 7533 segmentation fault  /usr/sbin/hwscan --floppy

strace ends with:

open("/proc/apm", O_RDONLY)             = -1 ENOENT (No such file or directory)
open("/dev/mem", O_RDONLY)              = 3
lseek(3, 1024, SEEK_SET)                = 1024
read(3, 0x50a080, 256)                  = -1 EFAULT (Bad address)
close(3)                                = 0
--- SIGSEGV (Segmentation fault) @ 0 (0) ---
+++ killed by SIGSEGV +++



