From: Andi Kleen <ak@suse.de>
Date: Wed, 04 Aug 2004 17:05:50 +0000
Subject: Re: Self-tuning logic for the time interpolators?
Message-Id: <20040804170550.GC11387@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408040934080.14500@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408040934080.14500@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +	else {
> +		/* Check for the necessity to adjust every minute
[...]
> +		if (jiffies >= 2*TIME_ADJUST_COUNTDOWN) {

But INITIAL_JIFFIES is ((unsigned long)(unsigned int) (-300*HZ))
It will probably not do what you want.


-Andi
