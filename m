From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 03 Aug 2005 05:35:22 +0000
Subject: Re: [lia64-sim] ski fails to complete boot with debian root fs
Message-Id: <42F0579A.1030904@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <17133.28762.225647.407409@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17133.28762.225647.407409@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb schrieb:

>Hi,
>	Using the current kernel (2.6.13-rc3), and sim_defconfig, and
>a debian root filesystem created with debootstrap, the kernel boots,
>then when attempting to log in as root, displays /etc/issue then hangs.
>
>At this point, it is constantly calling
>do_page_fault->handle_mm_fault->pte_fault to try to populate address
>0x6007fffffff8000 (Is that the right number of Fs ?) apparently
>succeeding, then retrying the fault on return to user space (the value
>in question is held in the bspst register)
>
>Rebuilding with CONFIG_ITANIUM works around the problem.
>
>
>Is there any way to tell Ski which processor to simulate?  It seems to
>return Itanium 2 in the cpuid register.
>
What Ski simulates is quite close to an Itanium 2. Can you catch the bug 
with the tracing facility?

>I'm using Glibc 2.3.2.ds1-22 (debian unstable), bash 3.0-15, and ski
>version v0.9.81-1 on IA64.
>
The current version is 0.9.81-l6. But I don't know the current 
maintainer at HP. Maybe someone from HP want to comment on this.

Christian

