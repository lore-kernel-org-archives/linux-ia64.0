From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Sep 2004 16:10:45 +0000
Subject: RE: 2.6.9-rc2-mm2
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020ED221@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040922232330.2cec2a08.akpm@osdl.org>
In-Reply-To: <20040922232330.2cec2a08.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Jesse Barnes <jbarnes@engr.sgi.com>
Cc: peterc@gelato.unsw.edu.au, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>It looks like Tony is wearing the BPB.  The below patch from
                                   ^^^?
Huh?  I can tell from context that this is all my fault (to which
I agree; it is), but what does "BPB" stand for?

>Process question: how is it possible that the ia64 tree could have been
>this dead for this long?

Because we have immense confusion about which combinations of
config options (NUMA, DISCONTIG, VIRTUAL_MEM_MAP, SMP) are
supported.  Kconfig allows almost any combination of them, but on
any given week only some combinations work.  The patch that broke
things for you came in to fix a problem for Peter.

I'll take a look at this.  Can you post the .config that you
are using.

-Tony
