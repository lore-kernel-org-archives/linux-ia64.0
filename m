From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 10 Dec 2002 17:46:50 +0000
Subject: Re: [Linux-ia64] Re: Configurable NUMA node memory size
Message-Id: <marc-linux-ia64-105590709805538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805530@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805530@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 10, 2002 at 06:35:04PM +0100, Erich Focht wrote:
> On Tuesday 10 December 2002 02:33, Jesse Barnes wrote:
> > Erich, could you please check out the discontig bits (mmzone.h) in the
> > SN update patch I posted today?  I renamed DIG_BANKSHIFT to just
> > BANKSHIFT so it could be reused, but I'm not sure if I did it correctly.
> 
> Looks good. Renaming is fine with me. I guess you'll have to rediff
> the patch for David in case he takes the configurable banksize in.

Great, thanks Erich.  Hopefully David will take your change since I have
to rediff anyway.

Jesse

