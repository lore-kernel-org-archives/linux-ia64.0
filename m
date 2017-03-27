From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 27 Mar 2017 10:46:40 +0000
Subject: Re: [RESEND PATCH v4 5/5] powerpc/fadump: update documentation about crashkernel parameter reuse
Message-Id: <87mvc7dmjz.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <149035332237.6881.9486330442785822384.stgit@hbathini.in.ibm.com> <149035347559.6881.14224829694291758581.stgit@hbathini.in.ibm.com>
In-Reply-To: <149035347559.6881.14224829694291758581.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, dyoung@redhat.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Hari Bathini <hbathini@linux.vnet.ibm.com> writes:

> As we are reusing crashkernel parameter instead of fadump_reserve_mem
> parameter to specify the memory to reserve for fadump's crash kernel,
> update the documentation accordingly.
>
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> ---
>  Documentation/powerpc/firmware-assisted-dump.txt |   23 ++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers
