From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 22 Jul 2003 21:26:24 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105890923804797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2003 at 08:22:37AM -0700, Luck, Tony wrote:

> I tried some similar code for Tiger a while ago, but ran into a
> problem as there is other code in the same granule, that isn't
> covered by the address range for PAL routines (I think that the
> other code was the EFI loaded FPSWA code, but I didn't look too
> closely at the time this happened).

Can you send me the memmap for this situation if possible please?

I have an algorithmic approach that should work everywhere but
obviously this requires that *ANY* code executed WB in the same
granule be visible in the EFI memory map so I can be sure to include
those when trying to find the minimum suitable TR to use.

The kicker here of course is that if some code is omitted (not
delcared) in the EFI memory map but actively used...  does anyone do
this?



  --cw
