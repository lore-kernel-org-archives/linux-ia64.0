From: Paul Jackson <pj@sgi.com>
Date: Thu, 12 Jan 2006 00:09:37 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060111160937.921a719d.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com
Cc: tony.luck@gmail.com, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, steiner@sgi.com, djh@sgi.com, jh@sgi.com, edwardsg@sgi.com

When I tried to build a 2.6.15-mm2 kernel with NR_CPUS 1024, and turned
on some of the LOCK DEBUG options:

    1160c1160
    < # CONFIG_DEBUG_SLAB is not set
    ---
    > CONFIG_DEBUG_SLAB=y
    1163,1164c1163,1164
    < # CONFIG_DEBUG_SPINLOCK is not set
    < # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
    ---
    > CONFIG_DEBUG_SPINLOCK=y
    > CONFIG_DEBUG_SPINLOCK_SLEEP=y

then the build failed:

      LD      .tmp_vmlinux1
    arch/ia64/kernel/built-in.o(.init.text+0x68b2): In function `topology_init':
    arch/ia64/kernel/ivt.S:1465: undefined reference to `__you_cannot_kmalloc_that_much'
    make: *** [.tmp_vmlinux1] Error 1

Backing off to 512 CPUs built ok.

There are a couple of kmalloc() calls in topology_init().  I didn't try
to figure out which one blew up, nor did I try to investigate further.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
