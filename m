From: Bill Nottingham <notting@redhat.com>
Date: Thu, 11 Jan 2001 22:03:46 +0000
Subject: [Linux-ia64] Re: Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
> >>>>> On Thu, 11 Jan 2001 11:09:22 -0800, Uros Prestor <uros@turbolinux.com> said:
> 
>   Uros> I still get a kernel panic in dtlb_fault() when setting
>   Uros> CONFIG_DISABLE_VHPT=y.
> 
> Are you sure you picked up the new kernel?  Try "objdump -d" on
> vmlinux and verify that itlb_fault ends with "b0" being restored.

Yup; a kernel with Asit's patch fails if CONFIG_DISABLE_VHPT is on,
succeeds if it's off. Oddly enough, I got an 'illegal instruction',
IIRC; the oops address was inside page_fault.

Bill

