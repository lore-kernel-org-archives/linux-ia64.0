From: Matthew Wilcox <willy@debian.org>
Date: Mon, 18 Aug 2003 16:13:31 +0000
Subject: Re: 2.6.0-test3: #undef SMP && #define NUMA does not compile
Message-Id: <marc-linux-ia64-106122322729771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106122187228169@msgid-missing>
In-Reply-To: <marc-linux-ia64-106122187228169@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 18, 2003 at 06:05:26PM +0200, Andreas Schwab wrote:
> Matthew Wilcox <willy@debian.org> writes:
> 
> |> On Mon, Aug 18, 2003 at 05:46:17PM +0200, Andreas Schwab wrote:
> |> > When configuring 2.6.0-test3 with CONFIG_SMP disabled and CONFIG_NUMA
> |> > enabled I get undefined references to cpu_to_node_map and
> |> > node_to_cpu_mask.  Both variables are defined in
> |> > arch/ia64/kernel/smpboot.c, thus only available for SMP.
> |> 
> |> Surely we should make NUMA depend on SMP?  Or does someone have an
> |> example of a NUMA single-processor box ;-)
> 
> One might want to boot an UP kernel on a NUMA box, would that still work?

I don't see why it shouldn't ... if it doesn't, I'd say that's a bug.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
