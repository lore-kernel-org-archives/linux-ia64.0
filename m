From: Andrew Morton <akpm@osdl.org>
Date: Fri, 06 Feb 2004 08:43:46 +0000
Subject: Re: gcc problems
Message-Id: <20040206004346.225040c0.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
>
> On Fri, Feb 06, 2004 at 12:00:58AM -0800, Andrew Morton wrote:
> > gcc-3.3.2/ia64 is falling over here with my current tree so I'm trying to
> > build gcc-3.4 from current gcc CVS.
> 
> That probably shouldn't be happening... It's what we use all the time.
> I assume gcc is segfaulting?

I rebuilt and it went away.  It could have been a 2.6 kernel bug ;)

> > Is there some trick to this?  And what is the preferred gcc version for
> > ia64 kernels?
> 
> Well I don't know exactly about that CVS gcc problem, but something
> that may be useful if you use Debian is that there is a little known
> 'gcc-snapshot' package that is usually quite up to date and saves you
> having to build yourself.  See the README.Debian for a sample wrapper.
> 

I would prefer to build gcc direct from the gcc team, really, thanks.

