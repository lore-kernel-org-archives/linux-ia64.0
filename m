From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 21 Sep 2005 18:31:30 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <20050921183130.GA13948@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050921182143.GA30873@sgi.com>
In-Reply-To: <20050921182143.GA30873@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 21, 2005 at 10:45:37PM -0700, David Mosberger-Tang wrote:
> On 9/21/05, Jack Steiner <steiner@sgi.com> wrote:
> 
> > In 2002, Gary Hade posted a patch to binutils that added dispersal
> > analysis to the output of objdump. Does anyone know what happened to
> > the patch? Is there another tool that provides the same information?
> 
> Yeah, a tool called Montecito! ;-)
> 

Indeed.

> I don't remember whether you were at the last Gelato meeting and
> whether you attended the PMU talk.  If you didn't: I had some slides
> in there that showed how the IP-EAR can be used to get
> instruction-group issue traces which show you exactly how many
> stall-cycles there are between subsequent instruction-groups.  Yes,
> that's a bit different from the static info you are looking for, but
> in many ways it's much better info, so it's real (measured) data and
> takes into affect all corner cases, including memory latency etc.
> 

You can get the presentation at:
	http://www.gelato.org/pdf/may2005/gelato_may2005_profiling_eranian_callister.pdf
-- 
-Stephane
