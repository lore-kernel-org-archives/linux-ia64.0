From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 11 Jan 2001 20:23:08 +0000
Subject: RE: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks like there is another window that can cause this problem. I am looking
into the problem.

Thanks,
Asit


> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Thursday, January 11, 2001 11:36 AM
> To: Uros Prestor
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
> 
> 
> >>>>> On Thu, 11 Jan 2001 11:09:22 -0800, Uros Prestor 
> <uros@turbolinux.com> said:
> 
>   Uros> I still get a kernel panic in dtlb_fault() when setting
>   Uros> CONFIG_DISABLE_VHPT=y.
> 
> Are you sure you picked up the new kernel?  Try "objdump -d" on
> vmlinux and verify that itlb_fault ends with "b0" being restored.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


