From: Uros Prestor <uros@turbolinux.com>
Date: Wed, 10 Jan 2001 00:40:50 +0000
Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590678205907@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

>   Uros> The IP points inside the dtlb_fault code.  Any ideas what's
>   Uros> going on here?  The panic happens both with SMP and UP
>   Uros> kernels.  I have disabled the VHPT (CONFIG_DISABLE_VHPT=y).
>   Uros> Anything else I am missing?
>
> I don't think I tested the kernel with DISABLE_VHPT.

Enabling VHPT solved the problem.

Thanks,
Uros

--
Uros Prestor
uros@turbolinux.com




