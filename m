From: Kyle McMartin <kyle@mcmartin.ca>
Date: Thu, 25 May 2006 15:41:55 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <20060525154155.GB31604@skunkworks.cabal.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 25, 2006 at 08:40:48AM -0700, Luck, Tony wrote:
> > in the pre-Montecito IPF CPUs.  AFAIK, the exact same binary is even
> > used both for the Windows and Linux versions of IA32EL.
>
<snip>
> The rest of the ia32-el package is open source ... which should
> provide enough documentation on how the OS-level code interfaces
> to the instruction execution engine to allow it to be replaced.
> 

Possibly a stupid question, but I couldn't find any information in the
(afaik) only released Montecito documentation (the Optimization guide).

Has the br.ia completer been removed from the architecture? Or will
it generate a trap which can be caught and the translator invoked?

The doc only references added insns, not those removed from the arch.

Cheers,
	Kyle
