From: Dean Nelson <dcn@sgi.com>
Date: Tue, 21 Dec 2004 12:20:08 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20041221122008.GA21619@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 04, 2004 at 12:12:57PM +0100, Christoph Hellwig wrote:
> > > A single mutex wouldn't do it?  It doesn't exactly look like it's used in
> > > fast-paths
> > 
> > Yeah, you're right it's not a fast-path and a single mutex would work.
> > I kind of like putting the lock within the data structure it's protecting.
> > When you get the lock, you've already got the data of interest in your
> > cache (obviously this depends on the size of the structure and where in
> > the structure the data you're interested in resides). We're not talking
> > about very much memory lost because of this. (The way it is we only end
> > up with a total of two semaphores, instead of just one.)
> 
> Well, Linux is difficult.  First rule of thumb is keep it simple, and
> if you ever need a fastpath semaphore you're better of making it a separate
> entinity from the registration sempahore.

I agree with the idea of keeping things simple, and therefore started
replacing the per-channel semaphores (i.e., the sema field in the
xpc_registration structure) by a single semaphore for all channels.

I ran into a problem of sorts with xpc_disconnect(), which grabs the
single semaphore and then calls xpc_interface.disconnect() while
holding that semaphore. This function won't return until all connections
to remote partitions have disconnected, which can be a while. (The
waiting is necessary in order to guarantee that no thread will reference
anything in XPC once the module is unloaded.) This wasn't a problem when
there was a semaphore per channel, since you have to wait for an
'rmmod XPNET' to complete before you can do a subsequent 'insmod XPNET'.
But now one won't be able to do an insmod or rmmod of XPMEM during the
time an 'rmmod XPNET' is executing.

To not hold the semaphore across the call to xpc_interface.disconnect()
would require the addition of a 'flag' field in the xpc_registration
structure. This new field would be used to indicate whether a channel
is registered or not, and if registered, whether it is unregistering.
(Currently, the xpc_registration structure's 'func' field is used to
indicate whether a channel is registered or not, and holding the
semaphore keeps another process from registering the channel, since
we've cleared the 'func' field before calling xpc_interface.disconnect().)

I'm not sure that adding the 'flag' field is simpler than keeping things
the way they are with the per-channel semaphores.

Any thoughts?

Thanks,
Dean
