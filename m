From: Uros Prestor <uros@turbolinux.com>
Date: Wed, 10 Jan 2001 19:34:52 +0000
Subject: Re: [Linux-ia64] Undefined symbols
Message-Id: <marc-linux-ia64-105590693005016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205911@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205911@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:

> On Tue, 09 Jan 2001 18:03:20 -0800,
> Uros Prestor <uros@turbolinux.com> wrote:
> >     [root@borg linux]# egrep ' (jiffies|printk)' /proc/ksyms
> >     e000000000b44c58 jiffies_R__ver_jiffies
> >     e000000000a869f0 printk_R__ver_printk
>
> http://www.tux.org/lkml/#s8-8
>
> If you still get problems after that process, let me know.

It looks like `make dep' is broken if you're doing a parallel build.
For example, if I do

     # make mrproper
     # cp ../.config .
     # make oldconfig
     # make dep
     # find . -name "*.ver" | xargs fgrep jiffies
     ./include/linux/modules/ksyms.ver:#define
     __ver_sysctl_jiffies  smp_1d9a67c4
     ./include/linux/modules/ksyms.ver:#define
     sysctl_jiffies        _set_ver(sysctl_jiffies)
     ./include/linux/modules/ksyms.ver:#define
     __ver_proc_dointvec_jiffies   smp_f9e749ca
     ./include/linux/modules/ksyms.ver:#define
     proc_dointvec_jiffies _set_ver(proc_dointvec_jiffies)
     ./include/linux/modules/ksyms.ver:#define
     __ver_proc_doulongvec_ms_jiffies_minmax       smp_b3cd4e88
     ./include/linux/modules/ksyms.ver:#define
     proc_doulongvec_ms_jiffies_minmax_set_ver(proc_doulongvec_ms_jiffies_minmax)

     ./include/linux/modules/ksyms.ver:#define __ver_jiffies
     smp_0da02d67
     ./include/linux/modules/ksyms.ver:#define jiffies
     _set_ver(jiffies)

On the other hand, if I do the same as above except for `make -j2 dep'
I don't get any versioning info for jiffies.  Looks like parallel build
is broken.

Uros



--
Uros Prestor
uros@turbolinux.com




