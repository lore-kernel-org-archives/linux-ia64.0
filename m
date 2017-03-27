From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 27 Mar 2017 10:46:27 +0000
Subject: Re: [RESEND PATCH v4 4/5] powerpc/fadump: reuse crashkernel parameter for fadump memory reservation
Message-Id: <87poh3dmkc.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <149035332237.6881.9486330442785822384.stgit@hbathini.in.ibm.com> <149035346749.6881.911095631212975718.stgit@hbathini.in.ibm.com>
In-Reply-To: <149035346749.6881.911095631212975718.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, dyoung@redhat.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Hari Bathini <hbathini@linux.vnet.ibm.com> writes:

> fadump supports specifying memory to reserve for fadump's crash kernel
> with fadump_reserve_mem kernel parameter. This parameter currently
> supports passing a fixed memory size, like fadump_reserve_mem=<size>
> only. This patch aims to add support for other syntaxes like range-based
> memory size <range1>:<size1>[,<range2>:<size2>,<range3>:<size3>,...]
> which allows using the same parameter to boot the kernel with different
> system RAM sizes.
>
> As crashkernel parameter already supports the above mentioned syntaxes,
> this patch deprecates fadump_reserve_mem parameter and reuses crashkernel
> parameter instead, to specify memory for fadump's crash kernel memory
> reservation as well. If any offset is provided in crashkernel parameter,
> it will be ignored in case of fadump, as fadump reserves memory at end
> of RAM.
>
> Advantages using crashkernel parameter instead of fadump_reserve_mem
> parameter are one less kernel parameter overall, code reuse and support
> for multiple syntaxes to specify memory.
>
> Suggested-by: Dave Young <dyoung@redhat.com>
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> Reviewed-by: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>
> ---
>  arch/powerpc/kernel/fadump.c |   23 ++++++++++-------------
>  1 file changed, 10 insertions(+), 13 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers
