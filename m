From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 24 Aug 2011 19:51:31 +0000
Subject: Re: How performance critical is fsys_rt_sigprocmask()?
Message-Id: <1314215491.3611.49.camel@mfleming-mobl1.ger.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1314196796.3611.38.camel@mfleming-mobl1.ger.corp.intel.com>
In-Reply-To: <1314196796.3611.38.camel@mfleming-mobl1.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2011-08-24 at 09:13 -0600, David Mosberger-Tang wrote:
> Matt,
> 
> As I remember it, it was the single system-call on the critical path of
> libunwind.  Don't remember the numbers, but it was significant.

Interesting. So that'd be the critical path for things like performance
analysis tools that record stack traces? Yeah, I can see how you'd want
the stack trace recording to have very little overhead.

I guess I'll start writing ia64 assembly then...

-- 
Matt Fleming, Intel Open Source Technology Center

