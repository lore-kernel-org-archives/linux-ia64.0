From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 26 Jan 2006 03:50:04 +0000
Subject: Re: [PATCH 5/6] fix warning on test_ti_thread_flag()
Message-Id: <20060126035004.GA11543@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0601251814350.19174@pademelon.sonytel.be> <200601252002.k0PK2Mg31276@unix-os.sc.intel.com>
In-Reply-To: <200601252002.k0PK2Mg31276@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Geert Uytterhoeven' <geert@linux-m68k.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, parisc-linux@parisc-linux.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>

On Wed, Jan 25, 2006 at 12:02:21PM -0800, Chen, Kenneth W wrote:
> Geert Uytterhoeven wrote on Wednesday, January 25, 2006 9:19 AM
> > > I don't think you need to change the flags size.
> > 
> > Passing a pointer to a 32-bit entity to a function that takes a
> > pointer to a 64-bit entity is a classical endianness bug. So it's
> > better to change it, before people copy the code to a big endian
> > platform.
> 
> Well, x86-64 and linux-ia64 both use little endian.  I don't
> understand why you are barking at us with big endian issue.
> 

I can fix this without changing the flags size for those architectures.

1. Introduce *_le_bit() bit operations which takes void *addr
   (already I have these functions in the scope of
    HAVE_ARCH_EXT2_NON_ATOMIC_BITOPS in my patch)

2. Change flags to __u8 flags[4] or __u8 flags[8] for each architectures.

3. Use *_le_bit() in include/linux/thread_info.h

