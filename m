From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Mar 2006 23:49:14 +0000
Subject: RE: Should we always wake up the non-monarch CPUs?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0605A043@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Yet, if the MCA cannot be recovered, what is the use of releasing
> the non-monarch CPUs from the rendez-vous?
> (It is much more easy to analyze the system state by use of some
> "external intelligence" if the non-monarch CPUs cannot run after
> an MCA for some considerably long time.)
> 
> As far as I can see in the flow chart of the MCA handling in the
> SAL spec. (Dec. 2003, figure 4-6, page 61), it indicates that a
> _typical_ MCA handler should wake up the non-monarch CPUs.

A few pages earlier (p.55 figure 4-3) has a box that says "OS_MCA
Correct error if possible; Wake up APs" with arrows coming out
for "Corrected" and "Uncorrected" ... which is just as unclear.

In practice it does seem pointless to wake the APs in the uncorrected
case (just to let them run for a while until the RESET hits).

-Tony
