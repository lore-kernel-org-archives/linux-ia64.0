From: Keith Owens <kaos@sgi.com>
Date: Thu, 04 Aug 2005 02:09:58 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <4575.1123121398@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 4 Aug 2005 11:42:08 +1000, 
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:
>>>>>> "Andreas" = Andreas Schwab <schwab@suse.de> writes:
>
>Andreas> I can't get 2.6.13-rc5 to boot, it crashes very early without
>Andreas> any sign of life, not even kdb can catch it.  Any idea?
>
>I'm seeing a similar problem with ZX machines... and serial console
>*is* enabled...
>
>I used configs/zx1_defconfig

2.6.13-rc5 works for me on SN2 boxes.  I could even boot an SN2 box
that was built using tiger_defconfig.

