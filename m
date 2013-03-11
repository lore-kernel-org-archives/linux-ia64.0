From: "Hartnett, Fred" <fred.hartnett@hp.com>
Date: Mon, 11 Mar 2013 22:42:17 +0000
Subject: RE: CMCI vector not initialized on BP
Message-Id: <D8D957864D852146A97B866681B1DF2F0D177879@G4W3207.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
In-Reply-To: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony - thanks for the response... appreciate this. If you follow register_percpu_irq you will discover it does not operate on CPU0 and the line ' ia64_mca_cmc_vector_setup()' operates on the current cpu which is typically not CPU0. It took some hacks in my kernel to prove this and ultimately show CPU CMCV is always 0x0.

smp_callin looks like the routine to iniatialize the vector table and the CMCI vector as well when the cpu  goes online. However smp_callin is not called for the BP.

Thanks - Fred



-----Original Message-----
From: Tony Luck [mailto:tony.luck@gmail.com] 
Sent: Monday, March 11, 2013 5:30 PM
To: Hartnett, Fred
Cc: linux-ia64@vger.kernel.org
Subject: Re: CMCI vector not initialized on BP

On Tue, Mar 5, 2013 at 3:05 PM, Hartnett, Fred <fred.hartnett@hp.com> wrote:
>  but the BP vector is not initialized since the BP is already online
    ...
> Is this by design or an oops?

Looks like we handle BSP in ia64_mca_late_init() [see below]. Are you seeing something that indicates that this isn't doing what the comment says it is doing?

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
