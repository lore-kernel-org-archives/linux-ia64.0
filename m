From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 19:07:08 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613608021679@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 20, 2003 at 12:02:03PM -0700, David Mosberger wrote:
> >>>>> On Fri, 20 Jun 2003 11:53:03 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> Yeah, that's what I meant.  Jack's patch to 2.4 has been
>   Jesse> tested on sn2, DIG, zx1, NEC, and Bull machines, as a generic
>   Jesse> kernel for the first three at least (don't know what NEC and
>   Jesse> Bull did for their testing).
> 
> But which ones are NUMA with node-scattered physical memory?  sn2 for

Do you mean discontiguous memory within a node?  Jack has the memory
maps for those other machines, so he might know.

>   Jesse> So you're worried about the performance penalty of turning on NUMA for
>   Jesse> generic kernels?
> 
> Yes.  Actually, I'm concerned about size, too.  It would be good to
> have an init-mem-like approach so that we can free all the code/data
> for unused machvec code.

That would be a nice thing to add, hmm...

Jesse
