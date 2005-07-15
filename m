From: Andi Kleen <ak@suse.de>
Date: Fri, 15 Jul 2005 11:46:16 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process
Message-Id: <20050715134616.43130b30@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
	<20050714230501.4a9df11e.pj@sgi.com>
In-Reply-To: <20050714230501.4a9df11e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Thu, 14 Jul 2005 23:05:01 -0700
Paul Jackson <pj@sgi.com> wrote:

> Christoph wrote:
> > This is an implementation that deals with monitoring and managing running 
> > processes.
> 
> So is this patch roughly equivalent to adding a pid to the
> mbind/set_mempolicy/get_mempolicy system calls?
> 
> Not that I am advocating for or against adding doing that.  But this
> seems like alot of code, with new and exciting API details, just to
> add a pid argument, if such it be.
> 
> Andi - could you remind us all why you chose not to have a pid argument
> in these calls?

Because of locking issues and I don't think external processes
should mess with virtual addresses of other processes. There is
just no way to do the later cleanly and race free.

I haven't seen the patch, but from the description it sounds wrong.

-Andi
