From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 09 Mar 2005 01:29:13 +0000
Subject: Re: PCI Express
Message-Id: <200503081729.15336.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, March 08, 2005 4:13 pm, Colin Ngam wrote:
> That's what I will find out before deciding to use it.  It is not used for
> IPIs on our platform, probably for very good reasons.

Yep, because IPIs generated from the local block to a distant processor won't 
work otherwise (afaik).

> If we can and the 
> address is the same than it is a no brainer.
>
> > targetted there should also work.  The problem for us is if a processor
> > tries to IPI a processor on a different node with the processor interrupt
> > block, which I don't think MSIs will try to do.
>
> Perhaps you can elaborate.  I am not sure what you are trying to say here.

The SHub manual is a little vague here, but my understanding is that in order 
to send remote IPIs we need to use the SHub, whereas local IPIs (i.e. 
processor to itself or to the other CPU on the same FSB) will work fine.

An MSI should behave like a processor sending an IPI to itself since its 
address can be targeted at the processor's interrupt block and set to 
generate a local interrupt.  Is that right, Tom & Grant?

If this won't work for us, no biggie, we just have to abstract things a little 
more.  We could make the MSI into a platform specific cookie that we can 
store a SHub/PIC/TIO address in and other platforms can use to target the 
processor interrupt block.  Hopefully we won't have to do that though, since 
it would require a few more changes.

Jesse
