From: john stultz <johnstul@us.ibm.com>
Date: Tue, 18 Nov 2003 01:08:40 +0000
Subject: Re: [RFC][PATCH] linux-2.4.23-pre9_ia64-cyclone_A0
Message-Id: <marc-linux-ia64-106911807105242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106911773604958@msgid-missing>
In-Reply-To: <marc-linux-ia64-106911773604958@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-11-17 at 17:02, john stultz wrote:
> On Mon, 2003-11-17 at 16:23, Bjorn Helgaas wrote:
> > SGI uses a similar design in 2.4, but apparently there are some
> > issues with it:
> > 	http://www.gelato.unsw.edu.au/linux-ia64/0310/6973.html
> > 
> > I'd like to see those issues resolved and the Cyclone support
> > put into the same framework as the SGI work.
> 
> Hmmm. I think I've grasped the issue there. It seems the problem is not
> calculating the equivalent of delay_at_last_interrupt found in the i386
> time code. I'll see if I cannot come up with something similar.

Actually, on second though, I don't believe this is necessary as every
tick we increment last_tick_cyclone by one tick, rather then zeroing it
out. In that way, even if the interrupt is delayed we don't lose time. 

I may be missing some subtlety, but I think the point made above was
considered in my patch. 

thanks
-john


