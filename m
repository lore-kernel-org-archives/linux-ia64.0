From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 17 May 2004 15:52:11 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084809130.24128.6199.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-05-17 at 01:38, Matthias Fouquet-Lapar wrote:
> I think I'm not quite sure why you need hotplug to balance CPUs between
> partitons. (You are not moving physical components for this, right ?)

Right, there is no movement of physical components. But, from Linux's
perspective, it really doesn't matter.  There is a cpu that I'm using,
it won't be there in a minute, I better stop using it.  That means that
Linux has to be careful with things like the for_each_cpu().   Take a
look at the calls to hotcpu_notifier() for more things that we keep an
eye on when CPUs go down.

That's pretty much what the CPU hotplug code does, and *that* doesn't
change whether the CPUs are real or more virtualized.

> > Remember, chips designs like the POWER4 tend to have a lot of cost and
> > design overhead in error correction and detection that are quite absent
> > from consumer type cpus.
> 
> Taken beside which CPU architecture has best the RAS features :-), which are
> CPU error types on ppc64 (besides cache SBE etc) which allow gracefully
> recovery (i.e. the OS continues operating and non-affected user processes
> continue to run) and hotplug replacement 

Sorry, I'm just a software guy.  No one tells me such things :)  

Rusty, have I butchered explaining CPU hotplug enough for you to step
in, yet?

-- Dave

