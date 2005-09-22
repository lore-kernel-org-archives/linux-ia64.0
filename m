From: Jack Steiner <steiner@sgi.com>
Date: Thu, 22 Sep 2005 16:58:42 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <20050922165841.GD32658@sgi.com>
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

Is montecito a free opensource tool   :-)
Sorry...


> 
> I don't remember whether you were at the last Gelato meeting and
> whether you attended the PMU talk.  If you didn't: I had some slides
> in there that showed how the IP-EAR can be used to get
> instruction-group issue traces which show you exactly how many
> stall-cycles there are between subsequent instruction-groups.  Yes,
> that's a bit different from the static info you are looking for, but
> in many ways it's much better info, so it's real (measured) data and
> takes into affect all corner cases, including memory latency etc.

Yes, I was at the meeting but I had forgotten about the IP-EAR  :-(

It looks like the IP-EAR will be useful in a lot of cases. However, a 
static analysis tool would also be useful. It would be nice to have both.

BTW, does the current version of pfmon support montecito? Are any 
perfmon.c kernel patches needed??



> 
>   --david
> --
> Mosberger Consulting LLC, voice/fax: 510-744-9372,
> http://www.mosberger-consulting.com/
> 35706 Runckel Lane, Fremont, CA 94536

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


