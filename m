From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Aug 2005 18:57:03 +0000
Subject: RE: Simulator bootloader fails with gcc 4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042C7DC7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Anyway, I looked quickly at the simulator code. I don't see anything
>wrong on that side. On SSC_COMPLETION, you end up doing a byte by byte
>memcpy for copyin for disk_stat and a byte by byte for copyout. Not much
>could go wrong there. The definition for disk_stat is identical (w/o the
>aligned attribute).

Ah ... but gcc has an unpleasant habit of inlining memcpy() calls.  This
is really annoying when you have taken the trouble to replace code
does a structure copy with an explicit call to memcpy() becuase
you know that one of the source or destination is unaligned, only
to have gcc generate some inline ld8/st8 instructions.

-Tony
