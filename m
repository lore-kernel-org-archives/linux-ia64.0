From: Gary Hade <garyhade@us.ibm.com>
Date: Thu, 22 Sep 2005 17:30:09 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <20050922173009.GA4699@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050921182143.GA30873@sgi.com>
In-Reply-To: <20050921182143.GA30873@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 21, 2005 at 11:31:30AM -0700, Stephane Eranian wrote:
> On Wed, Sep 21, 2005 at 10:45:37PM -0700, David Mosberger-Tang wrote:
> > On 9/21/05, Jack Steiner <steiner@sgi.com> wrote:
> > 
> > > In 2002, Gary Hade posted a patch to binutils that added dispersal
> > > analysis to the output of objdump. Does anyone know what happened to
> > > the patch? Is there another tool that provides the same information?
> > 
> > Yeah, a tool called Montecito! ;-)
> > 
> 
> Indeed.
> 
> > I don't remember whether you were at the last Gelato meeting and
> > whether you attended the PMU talk.  If you didn't: I had some slides
> > in there that showed how the IP-EAR can be used to get
> > instruction-group issue traces which show you exactly how many
> > stall-cycles there are between subsequent instruction-groups.  Yes,
> > that's a bit different from the static info you are looking for, but
> > in many ways it's much better info, so it's real (measured) data and
> > takes into affect all corner cases, including memory latency etc.
> > 
> 
> You can get the presentation at:
> 	http://www.gelato.org/pdf/may2005/gelato_may2005_profiling_eranian_callister.pdf

Good stuff.

One concern I had 3+ years ago when we proposed dispersal analysis 
inclusion in binutils was the likelyhood that the code would keep 
pace as the processor evolved.  The number of users of such 
specialized functionality is obviously very small and I was 
skeptical that a subset of those users would also be interested 
in keeping the dispersal analysis code updated... especially if 
there were other analysis alternatives.

Gary

-- 
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc
