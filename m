From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 19 Oct 2004 23:05:48 +0000
Subject: Re: [Patch] Altix patch 012-huberror for 2.6.10
Message-Id: <200410191605.49033.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.3.96.1041019151446.144128E-100000@fsgi900.americas.sgi.com>
In-Reply-To: <Pine.SGI.3.96.1041019151446.144128E-100000@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, October 19, 2004 1:52 pm, Luck, Tony wrote:
> I've applied up to and including the 012 patch and pushed
> the whole thing up to the new tree on bkbits:
>
>  http://lia64.bkbits.net/linux-ia64-release-2.6.10
>
> So you should pull from there and make sure it all builds
> for you before I send the "please do a bk pull" message to
> Linus.  Please send me an ACK when you've tested it.

ACK.  I've tested it on a small system and it comes up ok.  I'll run it 
through sparse and do some more testing tomorrow (and I'm sure Pat will too), 
but I'd say it's ok for Linus to pull at this point.  We'll no doubt run into 
a few small things, but those will have to get fixed anyway, no reason to 
hold up wider testing.

Thanks,
Jesse
