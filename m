From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 19 Jan 2005 03:20:46 +0000
Subject: Re: [Lmbench-users] Re: pipe performance regression on ia64
Message-Id: <Pine.LNX.4.58.0501181917210.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501181741.j0IHfGf30058@unix-os.sc.intel.com>
 <Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org> <16877.21998.984277.551515@napali.hpl.hp.com>
 <Pine.LNX.4.58.0501181200460.8178@ppc970.osdl.org> <20050119030506.GA19700@work.bitmover.com>
In-Reply-To: <20050119030506.GA19700@work.bitmover.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Larry McVoy <lm@bitmover.com>
Cc: davidm@hpl.hp.com, carl.staelin@hp.com, "Luck, Tony" <tony.luck@intel.com>, lmbench-users@bitmover.com, linux-ia64@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>



On Tue, 18 Jan 2005, Larry McVoy wrote:
> 
> I'm very unthrilled with the idea of adding stuff to the release benchmark
> which is OS specific.  That said, there is nothing to say that you can't
> grab the benchmark and tweak your own test case in there to prove or 
> disprove your theory.

Hmm.. The notion of SMP and CPU pinning is certainly not OS-specific (and
I bet you'll see all the same issues everythwre else too), but the
interfaces do tend to be, which makes it a bit uncomfortable..

			Linus
