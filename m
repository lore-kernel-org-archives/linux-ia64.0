From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 18 Apr 2003 14:38:16 +0000
Subject: [Linux-ia64] Re: [BUG] perfmon doesn't send SIGPROF in kernel 2.5.64
Message-Id: <marc-linux-ia64-105590723705562@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eric,

On Fri, Apr 18, 2003 at 02:00:19PM +0200, Eric Piel wrote:
> Stephane Eranian wrote:
> > 
> > The attached patch against 2.5.67 corrects the problem. Note that this
> > patch also includes other updates.
> > 
> > Let me know how it goes.
> Very good, it worked!:

I glad to see that it worked for you as well this time.

> 
> Also, after a quick glance at the patch I noticed this update:
> -/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL,
> 0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
> {0UL,0UL, 0UL, 0UL}},
> -/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL,
> 0xffffffff9fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
> {0UL,0UL, 0UL, 0UL}},
> +/* pmc8  */ { PFM_REG_CONFIG  , 0, 0xffffffff3fffffffUL,
> 0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
> {0UL,0UL, 0UL, 0UL}},
> +/* pmc9  */ { PFM_REG_CONFIG  , 0, 0xffffffff3ffffffcUL,
> 0xffffffff3fffffffUL, NULL, pfm_mck_pmc_check, {0UL,0UL, 0UL, 0UL},
> {0UL,0UL, 0UL, 0UL}},
> 
> Could you describe shortly what this is suppose to fix? Recently I had
> some troubles with some PMU counters on Itanium2 (hard to trigger) and I
> wonder if this could be solved by that patch...
> 

This only affects measurements made with the opcode matchers. The UIUC
folks reported a problem with certain opcode pattern not being counted
properly. I was off by one bit in the mask. This has no  affect on
measurements NOT using the opcode matchers.

-- 
-Stephane

