From: Tony Luck <tony.luck@gmail.com>
Date: Mon, 19 Sep 2005 06:51:08 +0000
Subject: Re: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <12c511ca05091823511d661f68@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/18/05, Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> Sure, but itc_ratio.num and itc_ratio.den (which are the only bits
> affected, unless I've severely miscalculated the match between format
> and args) are both 32-bit quantities

Very odd.  I don't see a warning with the current code (using gcc 3.4).
But when I applied this patch, I did get a warning (which is what made
me take a closer[1] look at this part).

-Tony

[1] not close enough, because I obviously didn't match the arguments
before sending the e-mail.
