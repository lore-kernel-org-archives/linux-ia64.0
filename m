From: mita@miraclelinux.com (Akinobu Mita)
Date: Fri, 27 Jan 2006 04:43:04 +0000
Subject: Re: [PATCH 8/12] generic hweight{32,16,8}()
Message-Id: <20060127044303.GA6594@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com> <20060126033613.GG11138@miraclelinux.com> <1138301867.12632.71.camel@serpentine.pathscale.com>
In-Reply-To: <1138301867.12632.71.camel@serpentine.pathscale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bryan O'Sullivan <bos@serpentine.com>
Cc: Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, Jan 26, 2006 at 10:57:47AM -0800, Bryan O'Sullivan wrote:

> How about putting each class of bitop into its own header file in
> asm-generic, and getting the arches that need each one to include the
> specific files it needs in its own bitops.h header?
> 

I think it's better than adding many HAVE_ARCH_*_BITOPS.
I will have 14 new headers. So I want to make new directory
include/asm-generic/bitops/:

include/asm-generic/bitops/atomic.h
include/asm-generic/bitops/nonatomic.h
include/asm-generic/bitops/__ffs.h
include/asm-generic/bitops/ffz.h
include/asm-generic/bitops/fls.h
include/asm-generic/bitops/fls64.h
include/asm-generic/bitops/find.h
include/asm-generic/bitops/ffs.h
include/asm-generic/bitops/sched-ffs.h
include/asm-generic/bitops/hweight.h
include/asm-generic/bitops/hweight64.h
include/asm-generic/bitops/ext2-atomic.h
include/asm-generic/bitops/ext2-nonatomic.h
include/asm-generic/bitops/minix.h

