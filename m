From: Jason Baron <jbaron@redhat.com>
Date: Tue, 04 May 2004 19:01:56 +0000
Subject: RE: IPC_STAT on ia64
Message-Id: <Pine.LNX.4.44.0405041459220.26563-100000@dhcp64-180.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8BF7471D09AA9B4190A9C96778BC2A170108B854@qcaexc02.asiapacific.cpqcorp.net>
In-Reply-To: <8BF7471D09AA9B4190A9C96778BC2A170108B854@qcaexc02.asiapacific.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 4 May 2004, ARADHYA, CHINMAYA TM (STSD) wrote:

> I ran the test on Kernel ver 2.4.21, The behaviour was sane.
> 
> There were indeed some IPC_STAT related issues fixed in this
> version. 
> 
> >>>>>>>
> 2.4.21 Fixes
> 
> * IA32 emulation:
>     .
>     .
>     .
>     - fix shmctl(IPC_STAT) (Arun Sharma).
> >>>>>>>>
> 
> thx
> Chinmaya

This has been fixed for quite some time in RHEL 2.1 as well.  2.4.18-e.43
is the current kernel version, while 2.4.18-e.12, was the original kernel
version from 2 years ago.

-Jason



