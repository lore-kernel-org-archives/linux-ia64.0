From: "Carlos O'Donell" <carlos@baldric.uwo.ca>
Date: Mon, 05 Jan 2004 19:31:54 +0000
Subject: Re: [carlos@baldric.uwo.ca: Good news for glibc.]
Message-Id: <20040105193154.GA9157@systemhalted>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040105183349.GC9004@colo.lackof.org>
In-Reply-To: <20040105183349.GC9004@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 05, 2004 at 11:06:38AM -0800, David Mosberger wrote:
> I'd recommend q-tools.  It will give you a (statistically collected)
> call-graph, in addition to the flat profile and is completely
> unintrusive (no recompilation etc needed).  See my post for details:
> 
>   http://marc.theaimsgroup.com/?l=linux-ia64&m7075994721581
> 
> Oh, yeah, I'm slightly biased... ;-)

Indeed! Looks very cool though.

> The one limitation is that it doesn't work well for short-lived
> processes.  Also, it works in system-wide mode (collects info for
> _all_ processes that happen to run over a given period of time).
> 
> If you want per-process profiling, you could use qprof.  It doesn't do
> call-graphs (yet) and only works for dynamically linked programs, but
> it's very easy to use.  See:
> 
>   http://www.hpl.hp.com/research/linux/qprof/

Looks good, It was just my wish to get LD_PROFILE working, what's easier
than tacking on an environment variable to get a quick look at the calls
made by a particular DSO?

I'm 99.9% sure if upstream takes my patches this will fix LD_PROFILE
for ia64 aswell.

c.

