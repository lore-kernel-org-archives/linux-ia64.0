From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 03 Nov 2004 16:22:45 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <200411030822.45423.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, November 2, 2004 10:15 pm, Takayoshi Kochi wrote:
> Hi,
>
> From: "Luck, Tony" <tony.luck@intel.com>
> Subject: RE: [PATCH] top level scheduler domain for ia64
> Date: Tue, 2 Nov 2004 13:31:16 -0800
>
> > >> I think the short-term solution is to make the boot-time parameter
> > >> like Jesse said to control the creation and span size of the
> > >> node domain and see what is necessary next.
> > >
> > >This patch adds a new kernel parameter "nodes_per_domain"
> > >which specifies how many nodes are included in a node
> > >scheduling domain.
> >
> > Can you add a short write-up for Documentation/kernel-parameters.txt
> > to explain the effect, and how a user should pick what value to use
> > (examples would be good ... if SGI want to throw in some
> > values for small/large Altix boxes, that would be good too).
>
> The diff is attached.
> Though I'm not sure how to pick the best number...
> Any ideas from SGI?
>
> > Is '6' a reasonable default if the parameter is not set?
>
> Maybe for Altix.  I guess the only user of this domain split
> is Altix, so it's ok ;)

Yep, looks good to me.  Thanks.

Jesse
