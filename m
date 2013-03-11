From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 11 Mar 2013 22:29:59 +0000
Subject: Re: CMCI vector not initialized on BP
Message-Id: <CA+8MBb+CuT5dYeLXzU-B=4FGYDJfd7RYPt389pDt0wmyOESCRA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
In-Reply-To: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 5, 2013 at 3:05 PM, Hartnett, Fred <fred.hartnett@hp.com> wrote:
>  but the BP vector is not initialized since the BP is already online
    ...
> Is this by design or an oops?

Looks like we handle BSP in ia64_mca_late_init() [see below]. Are
you seeing something that indicates that this isn't doing what the
comment says it is doing?

-Tony

static int __init
ia64_mca_late_init(void)
{
        if (!mca_init)
                return 0;

        /*
         *  Configure the CMCI/P vector and handler. Interrupts for CMC are
         *  per-processor, so AP CMC interrupts are setup in
smp_callin() (smpboot.c).
         */
        register_percpu_irq(IA64_CMC_VECTOR, &cmci_irqaction);
        register_percpu_irq(IA64_CMCP_VECTOR, &cmcp_irqaction);
        ia64_mca_cmc_vector_setup();       /* Setup vector on BSP */
