From: Greentime Hu <green.hu@gmail.com>
Date: Thu, 06 Sep 2018 02:33:48 +0000
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
Message-Id: <CAEbi=3dKL1zOYc0DC3yXm=7srw6tUfx-JR=o9n4pVrGp+Sosug@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: rppt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org, mingo@redhat.com, mpe@ellerman.id.au, mhocko@suse.com, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux <sparclinux@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Mike Rapoport <rppt@linux.vnet.ibm.com> 於 2018年9月6日 週四 上午12:04寫道：
>
> Hi,
>
> These patches switch early memory managment to use memblock directly
> without any bootmem compatibility wrappers. As the result both bootmem and
> nobootmem are removed.
>
> There are still a couple of things to sort out, the most important is the
> removal of bootmem usage in MIPS.
>
> Still, IMHO, the series is in sufficient state to post and get the early
> feedback.
>
> The patches are build-tested with defconfig for most architectures (I
> couldn't find a compiler for nds32 and unicore32) and boot-tested on x86
> VM.
>
Hi Mike,

There are nds32 toolchains.
https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0/x86_64-gcc-8.1.0-nolibc-nds32le-linux.tar.gz
https://github.com/vincentzwc/prebuilt-nds32-toolchain/releases/download/20180521/nds32le-linux-glibc-v3-upstream.tar.gz

Sorry, we have no qemu yet.
