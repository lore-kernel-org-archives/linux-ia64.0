From: Uros Prestor <uros@turbolinux.com>
Date: Sat, 09 Sep 2000 21:25:00 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.0-test8)
Message-Id: <marc-linux-ia64-105590678205472@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>   HJ> as soon as it booted. I am enclosing my .config here. BTW, the
>   HJ> kernel from the 0828 Turbo Linux booted fine. I am enclosing the
>   HJ> boot message here also. Any ideas?
>
> You didn't describe how the new kernel failed, so there isn't much I
> can do.

The kernel doesn't get to print anything.  I will recompile with early printk
enabled to see if I get any more output but basically as soon as lilo passes the
control to kernel the system locks up.  I was only booting UP kernel even though
I am running 2xB1 BigSur.

I tried both BIOS 60 and BIOS 70 -- test8 locks up on both.  Additionally,
I noticed that when booting a SMP test7 kernel under BIOS 70 the kernel
recognizes only one processor.  I'm downgrading back to BIOS 60.

Uros


--
Uros Prestor
uros@turbolinux.com




