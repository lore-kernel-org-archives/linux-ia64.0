From: Dean Nelson <dcn@sgi.com>
Date: Thu, 21 Oct 2004 11:01:57 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20041021110157.GA26638@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 21, 2004 at 09:59:27AM +0100, Christoph Hellwig wrote:
> On Tue, Sep 14, 2004 at 01:58:37PM -0500, Dean Nelson wrote:
> > > As said previously you're not supposed to mess with this one.
> > 
> > Yeah, I know, but how is one suppose to deal with the following
> > issue raised by Robin? (Never did get a response from you.)
> > 
> > On Wed, Jun 16, 2004 at 02:36:22PM -0500, Robin Holt wrote:
> > > On Wed, Jun 16, 2004 at 06:43:47PM +0100, Christoph Hellwig wrote:
> > > > On Wed, Jun 16, 2004 at 12:40:53PM -0500, Robin Holt wrote:
> > > > > > > +EXPORT_SYMBOL(sys_sched_setscheduler);
> > > > > >
> > > > > > Again, don't mess with scheduler paramters from your modules.
> > > > >
> > > > > How should a kernel thread raise itself to real-time priority?
> > > >
> > > > Answer to both:  it shouldn't
> > >
> > > To the second, we found that contention would result in very high
> > > latency without raising the priority to real-time levels.  What is
> > > the proper way to handle having a user thread at the same priority
> > > as a kernel thread causing this holdoff?
> > 
> > The problem arises when enough user processes, which have the same
> > priority as XPC's kthreads, are spinning doing a bit of work mixed
> > with sleeping. Because of the sleep, these processes get a bonus
> > which gives them a higher effective priority than the XPC kthreads.
> > As a result, when cross partition interrupts come in, the XPC kthreads
> > do not get scheduled immediately, but are held off until the end of
> > the user processes' time slice.
> > 
> > This problem was encountered running a legitimate user land work load.
> > I concocted the following program to reproduce the behavior we were
> > seeing. I did this to see if the problem still exists on the 2.6
> > kernel (we originally saw the problem running on 2.4).
> 
> Any reason you're doing that work from thread and not tasklets that
> get scheduled ASAP?

Yeah, these threads may block for an indefinite period of time.

