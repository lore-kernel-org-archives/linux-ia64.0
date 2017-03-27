From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 27 Mar 2017 10:46:12 +0000
Subject: Re: [RESEND PATCH v4 3/5] powerpc/fadump: remove dependency with CONFIG_KEXEC
Message-Id: <87shlzdmkr.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <149035332237.6881.9486330442785822384.stgit@hbathini.in.ibm.com> <149035343956.6881.1536459326017709354.stgit@hbathini.in.ibm.com>
In-Reply-To: <149035343956.6881.1536459326017709354.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, dyoung@redhat.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Hari Bathini <hbathini@linux.vnet.ibm.com> writes:

> Now that crashkernel parameter parsing and vmcoreinfo related code is
> moved under CONFIG_CRASH_CORE instead of CONFIG_KEXEC_CORE, remove
> dependency with CONFIG_KEXEC for CONFIG_FA_DUMP. While here, get rid
> of definitions of fadump_append_elf_note() & fadump_final_note()
> functions to reuse similar functions compiled under CONFIG_CRASH_CORE.
>
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> Reviewed-by: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>
> ---
>  arch/powerpc/Kconfig               |   10 ++++++----
>  arch/powerpc/include/asm/fadump.h  |    2 ++
>  arch/powerpc/kernel/crash.c        |    2 --
>  arch/powerpc/kernel/fadump.c       |   34 +++-------------------------------
>  arch/powerpc/kernel/setup-common.c |    5 +++++
>  5 files changed, 16 insertions(+), 37 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers
