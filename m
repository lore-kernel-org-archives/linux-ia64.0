From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 19:56:00 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613900025498@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 20, 2003 at 09:44:13PM +0200, Andreas Schwab wrote:
> jbarnes@sgi.com (Jesse Barnes) writes:
> 
> |> This one Works For Me (tm).  Does it look ok?
> 
> Does it require other patches?

Yes, as it turns out.  You'll need the discontig patch I posted earlier.
2.5.69 used to build for me just fine without the patch, because it had
the right stuff in mmzone.h (or at least, some earlier version had it).
Don't know where that code went...

Jesse
