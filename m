From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 20:28:23 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105614117427625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 20, 2003 at 10:25:06PM +0200, Andreas Schwab wrote:
> jbarnes@sgi.com (Jesse Barnes) writes:
> 
> |> On Fri, Jun 20, 2003 at 09:44:13PM +0200, Andreas Schwab wrote:
> |> > jbarnes@sgi.com (Jesse Barnes) writes:
> |> > 
> |> > |> This one Works For Me (tm).  Does it look ok?
> |> > 
> |> > Does it require other patches?
> |> 
> |> Yes, as it turns out.  You'll need the discontig patch I posted earlier.
> 
> These patches overlap.  I had to delete the arch/ia64/Kconfig patch from
> the discontig patch.  Unfortunately, there are more problems
> (devfs_handle_t is private to devfs):
> 
>   CC      arch/ia64/sn/io/drivers/ifconfig_net.o
> arch/ia64/sn/io/drivers/ifconfig_net.c:40: error: parse error before "ifconfig_net_handle"
> arch/ia64/sn/io/drivers/ifconfig_net.c:40: warning: type defaults to `int' in declaration of `ifconfig_net_handle'
> arch/ia64/sn/io/drivers/ifconfig_net.c:40: warning: data definition has no type or storage class
> arch/ia64/sn/io/drivers/ifconfig_net.c: In function `init_ifconfig_net':
> arch/ia64/sn/io/drivers/ifconfig_net.c:285: warning: assignment makes integer from pointer without a cast
> arch/ia64/sn/io/drivers/ifconfig_net.c:290: warning: assignment makes integer from pointer without a cast
> arch/ia64/sn/io/drivers/ifconfig_net.c:292: warning: comparison between pointer and integer
> make[3]: *** [arch/ia64/sn/io/drivers/ifconfig_net.o] Error 1

Ugg, it never ends! :)  Yes, the patches overlap because I seperated out
and fixed the Kconfig changes from the discontig patch and posted them
in the last one, but haven't posted a new discontig yet.  It looks like
David hasn't applied my last sn2 update either, so you'll need that as
well (I posted it yesterday too, I think).

Thanks for trying to test this out!

Jesse
