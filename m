From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Jun 2004 07:22:40 +0000
Subject: Re: Real time clock on ia64 platforms
Message-Id: <20040602072240.GC27448@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40BC3558.7040606@hob.de>
In-Reply-To: <40BC3558.7040606@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 02, 2004 at 08:26:53AM +0200, Christian Hildner wrote:
> Alex Williamson schrieb:
> 
> >On Tue, 2004-06-01 at 01:50, Christian Hildner wrote:
> > Why do you
> >need to poke it directly?
> >
> Because I need to call it from an environment, where no EFI calls are 
> possible. I know that the solution is absolutely not portable in any way 
> and in common it is bad doing that way but in that special case there is 
> no other way to go. And  the portability is given at another layer on 
> top of it.

What are you doing with it?  Can you just use ITC in the realtime sensitive
portion of your code and then convert ITC ticks back into clock time as
needed?

Robin Holt
