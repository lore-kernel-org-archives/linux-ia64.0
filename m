From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 09 Mar 2005 22:51:18 +0000
Subject: Re: cpu_to_node_map on UP systems
Message-Id: <200503091451.18448.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, March 9, 2005 11:31 am, Luck, Tony wrote:
> Yes, tiger builds ok with SMP=n (if you pull from the
> linux-ia64-test-2.6.12 you'll also gets Bjorn's fix to iosapic so the the
> resulting kernel will boot, rather than hang).
>
> There are still problems with building the generic kernel with SMP=n

I thought we had worked all these out awhile ago?  I assume you're merging all 
this stuff as fast as you can now that 2.6.12 is open?  Or do you need me to 
resend?  If so, let me know when you've got the bulk of your queue merged and 
I can fix things up, rediff and resend.

Thanks,
Jesse
