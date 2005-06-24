From: Russ Anderson <rja@sgi.com>
Date: Fri, 24 Jun 2005 20:18:04 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <200506242018.j5OKI4qs870202@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> Russ Anderson wrote:
> 
> > +	pmsa = (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state | (6ul<<61));
> > +	if (psr1->cpl != 0 || (pmsa->pmsa_iip >= (unsigned long)&interrupt &&
> > +			       pmsa->pmsa_iip <  (unsigned long)&interrupt_pnr)) {
> 
> It seems that the latter state just means "this was in early of interrupt."
> You shoud also make sure that the interrupt has happen in user context, right?

Yes, that is a good point.   The updated patch has that change.

------------------------------------------------------------------------------
        psr1 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
+       psr2 =(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_xpsr);

        /*
         *  Check the privilege level of interrupted context.
         *   If it is user-mode, then terminate affected process.
         */
-       if (psr1->cpl != 0) {
+       pmsa = (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state | (6ul<<61));
+
+       if (psr1->cpl != 0 || ((psr2->cpl != 0) &&
+                              (pmsa->pmsa_iip >= (unsigned long)ia64_ivt+0x3000 &&
+                               pmsa->pmsa_iip <  (unsigned long)&interrupt_pnr))) {
                smei = peidx_bus_check(peidx, 0);


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
