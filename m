From: Gerrit Huizenga <gerrit@sequent.com>
Date: Wed, 12 Jul 2000 17:43:57 +0000
Subject: Re: [Linux-ia64] Problem while compiling a module
Message-Id: <marc-linux-ia64-105590678205198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205196@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205196@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I had a similar problem simply compiling the kernel from the latest
redhat distro for ia64.  The problem was a couple of missing underscores
in include/linux/version.h on _module_up -> __module_up and _module_smp ->
__module_smp.

My "revised" version is as follows (sorry, I toasted the orig or I'd
send diffs, although they'd probably be larger.  ;-):

#include <linux/rhconfig.h>
#if defined(__module_up)
#define UTS_RELEASE "2.4.0-0.8"
#endif
#if defined(__module_smp)
#define UTS_RELEASE "2.4.0-0.8smp"
#endif
#define LINUX_VERSION_CODE 132096
#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))

gerrit


> Hi,
> 
> I'm trying to make a device driver on an Itanium, and while including
> <linux/module.h>, with the -DMODULE flag, I get the following problem:
> 
> /usr/include/linux/module.h:223: parse error before `UTS_RELEASE'
> 
> The line itself is:
> 
> static const char __module_kernel_version[]
> __attribute__((section(".modinfo"))) = 
> "kernel_version=" UTS_RELEASE;
> 
> Has anybody got a hint to solve this problem? (removing the line is a bad
> idea as I'm using UTS_RELEASE...)
> 
> 
> Geraud
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


