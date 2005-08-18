From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 18 Aug 2005 19:07:55 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050818190755.GA4925@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

On Thu, Aug 18, 2005 at 11:57:03AM -0700, Luck, Tony wrote:
> >Anyway, I looked quickly at the simulator code. I don't see anything
> >wrong on that side. On SSC_COMPLETION, you end up doing a byte by byte
> >memcpy for copyin for disk_stat and a byte by byte for copyout. Not much
> >could go wrong there. The definition for disk_stat is identical (w/o the
> >aligned attribute).
> 
> Ah ... but gcc has an unpleasant habit of inlining memcpy() calls.  This
> is really annoying when you have taken the trouble to replace code
> does a structure copy with an explicit call to memcpy() becuase
> you know that one of the source or destination is unaligned, only
> to have gcc generate some inline ld8/st8 instructions.

The simulator is not using the regular memcpy() routine it has its own
custom routine (which is not named memcpy).

-- 

-Stephane
