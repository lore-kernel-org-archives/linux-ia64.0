From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 08 May 2003 22:31:14 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705704@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 08, 2003 at 10:50:22AM -0700, David Mosberger wrote:
>   Jesse> Right, I thought about that.  I don't think we need text
>   Jesse> replication yet though anyway (at least our platform
>   Jesse> doesn't).
> 
> That's what I would have guessed.  I think it might be different for
> the 8870 chipset though.  Or does it have a huge L4 cache, too?

If they don't need it, would you be happy taking the simple reloc code
in elilo?  And it seems simple enough, so even if we have to throw it
away, no big loss.

Thanks,
Jesse

