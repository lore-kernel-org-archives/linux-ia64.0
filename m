From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 23:18:43 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504231843.GB3395@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 04:15:15PM -0700, David Mosberger wrote:
> >>>>> On Tue, 4 May 2004 16:11:35 -0700, Grant Grundler <iod00d@hp.com> said:
> 
>   Grant> HP chipsets (ZX1/SX1000) will hardfail - it's one of the
>   Grant> differences I point out in the "Porting drivers to ZX1"
>   Grant> OLS2002 paper I wrote.  Sounds like SGI chipsets behave the
>   Grant> same way.
> 
> Hmmh, I thought zx1 soft-fails on inX/outX?

I'll have to try it...none of the drivers I care use IO port
space or randomly attempt to poke around.

ISTR the graphics folks agonizing over this issue when bringing
up the radeon cards as console - the BIOS emulation in firmware was 
has issues with this same problem. Alex, remember more details?

grant
