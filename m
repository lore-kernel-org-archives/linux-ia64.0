From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 18 Mar 2003 00:29:23 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.21-pre5 kksymoops for i386/ia64
Message-Id: <marc-linux-ia64-105590709806149@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806140@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806140@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 17 Mar 2003 15:20:15 +0000, 
David Woodhouse <dwmw2@infradead.org> wrote:
>On Mon, 2003-03-17 at 08:02, Keith Owens wrote:
>> Automatic decoding of oops on 2.5 has been very useful, so this patch
>> adds kksymoops support to 2.4.21-pre5.  Currently only for i386 and
>> ia64, other architectures are easy to add.
>
>> +KALLSYMS	= /sbin/kallsyms
>
>Kallsyms is arch-specific, isn't it? So shouldn't that be
>$(CROSS_COMPILE)kallsyms?

kallsyms does not build in cross compile mode.  There are hacked up
versions of kallsyms for specific cross compile environments and the
user selects them by make KALLSYMS=...  I was going to make modutils
fully cross compile compatible but now it has moved into the kernel
there is no point.  Pity that the kernel version is incomplete.

>How does one go about making non-native kallsyms? 

Google for kallsyms i386 ia64.

>The 2.5 kallsyms doesn't break cross-compilation, does it?

No, but neither does it support the section data that is needed for kdb
(and possibly kgdb).  The removal of section data in 2.5 is one of the
reasons that I no longer do kdb patches for 2.5 kernels.  If you want
to destroy kdb for 2.4 kernels as well, go ahead and use the 2.5
kallsyms.  It will actually make my life easier if I no longer have to
support kdb on standard kernels.

This patch does not break cross compilation either.  It is a
restriction that you cannot use kallsyms in cross compile mode unless
you have a version like kallsyms_i386_ia64.


