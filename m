From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 10 Jun 2004 19:08:26 +0000
Subject: Re: wait4 causes segfault in i386 chroot
Message-Id: <40C8B1AA.5040307@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040610051605.GA21936@cse.unsw.EDU.AU>
In-Reply-To: <20040610051605.GA21936@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/9/2004 10:16 PM, Ian Wienand wrote:

> I've tracked it down to doing a wait/waitpid/wait4 (they all end up in
> wait4) in a sigchld signal handler.  If I do a minimal test case where
> I catch the sigchld and wait, once the call returns it segfaults as in
> this trace (gdb can't seem to give a good backtrace).
> 

I recall seeing this problem earlier. But I'm unable to reproduce it now. I tried with 2.4.x and 2.6.6. Will try 2.6.7-rc3 later today. What was your glibc version ?

	-Arun

