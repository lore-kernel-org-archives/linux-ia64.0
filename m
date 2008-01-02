From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 02 Jan 2008 09:54:01 +0000
Subject: Re: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <477B5F39.3090106@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Apparently, you reposted the same patch as you did on the 21st of November.

So let me ask again, why you use "volatile" here, why you need an ".acq"
on this load:

> +	m = (volatile __u32 *)addr + (nr >> 5);

I still think the right solution is in my post on the 22nd of November.

Thanks,

Zoltan Menyhart
