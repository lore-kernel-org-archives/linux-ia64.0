From: Andi Kleen <ak@suse.de>
Date: Mon, 22 Nov 2004 16:22:14 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <20041122162214.GE21861@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com>
In-Reply-To: <41A20AF3.9030408@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

On Mon, Nov 22, 2004 at 09:51:15AM -0600, Ray Bryant wrote:
> (Obviously, one solution is to recode the application to send fewer signals
> per thread as the number of threads increase.  However, we are concerned by
> the fact that a user application, of any kind, can be constructed in a way
> that causes system to become responsive and would like to find a solutiuon
> that would let us correctly execute the program as described.)

I suspect there are hundreds or thousands of ways on such a big system to 
exploit some lock to make the system unresponsive.  If you wanted
to fix them all your would be in a large scale redesign effort. 
It's not clear why this particular case is special.

> Since signals are sent much more often than sigaction() is called, it would
> seem to make more sense to make sigaction() take a heavier weight lock of

At least in traditional signal semantics you have to call sigaction
or signal in each signal handler to reset the signal. So that 
assumption is not necessarily true.

> It seems to me that scalability would be improved if we moved the siglock 
> from
> the sighand structure to the task_struct.  (keep reading, please...)  Code 
> that manipulates the current task signal data only would just obtain that 
> lock.  Code that needs to change the sighand structure (e. g. sigaction())
> would obtain all of the siglock's of all tasks using the same sighand 
> structure.  A list of those task_struct's would be added to the sighand
> structure to enable finding these structurs without having to take the
> task_list_lock and search for them.

Taking all these locks without risking deadlock would be tricky.
You could just use a ring, but would need to point to a common
anchor and always start from there to make sure all lock grabbers
aquire the locks in the same order.

> Anyway, we would be interested in the community's ideas about dealing with
> this signal delivery scalability issue, and, comments on the solution above
> or suggestions for alternative solutions are welcome.

How about you figure out a fast path of some signals that can work
without locking: e.g. no load balancing needed, no queued signal, etc. 
and then just do the delivery of SIGPROF lockless? Or just ignore it
since the original premise doesn't seem to useful.

-Andi

