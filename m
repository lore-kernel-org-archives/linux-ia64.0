From: Paul Mackerras <paulus@samba.org>
Date: Thu, 26 Jan 2006 04:12:37 +0000
Subject: Re: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <17368.19509.43692.401946@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0601251814350.19174@pademelon.sonytel.be>
	<200601252002.k0PK2Mg31276@unix-os.sc.intel.com>
	<20060126035004.GA11543@miraclelinux.com>
In-Reply-To: <20060126035004.GA11543@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, ultralinux@vger.kernel.org, Linux Kernel Development <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, 'Geert Uytterhoeven' <geert@linux-m68k.org>, sparclinux@vger.kernel.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, parisc-linux@parisc-linux.org

Akinobu Mita writes:

> I can fix this without changing the flags size for those architectures.
> 
> 1. Introduce *_le_bit() bit operations which takes void *addr
>    (already I have these functions in the scope of
>     HAVE_ARCH_EXT2_NON_ATOMIC_BITOPS in my patch)
> 
> 2. Change flags to __u8 flags[4] or __u8 flags[8] for each architectures.
> 
> 3. Use *_le_bit() in include/linux/thread_info.h

Please don't do this, you'll break the powerpc assembly code that
tests bits in thread_info()->flags.

Paul.
