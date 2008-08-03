From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 03 Aug 2008 02:43:28 +0000
Subject: Re: [patch] IA64: suppress return value of down_trylock() in salinfo_work_to_do()
Message-Id: <20080803024327.GE26461@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080803013159.GB26461@parisc-linux.org> <12597.1217729288@ocs10w>
In-Reply-To: <12597.1217729288@ocs10w>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@ocs.com.au>
Cc: Simon Horman <horms@verge.net.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Sun, Aug 03, 2008 at 12:08:08PM +1000, Keith Owens wrote:
> >task A acquires sem
> >
> >task B tries to acquire the sem, fails
> >task B releases the sem that it didn't acquire
> >
> >task A releases the sem, falls down, goes boom?
> 
> Cannot happen.  See the comment above the function:
> 
>   This routine must be called with data_saved_lock held, to make the down/up
>   operation atomic

... that requres one to know that salinfo_work_to_do() is the only place
which calls up() (and it always calls down_trylock first).  This is a
really creative misuse of semaphores.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
