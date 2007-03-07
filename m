From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 00:50:03 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070307005002.GD17090@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 06, 2007 at 04:23:37PM +0800, Zou, Nanhai wrote:
> 
> Hi Horms,
> 	I feel this is over-designed.
>      I think to specify crash kernel base address in command line is only useful for debug, on platform like SN this feature is totally unusable.At the most of time, user should let kernel to decide where to reserve crashdump region.
>     If a user wants to put crash kernel in command line, he should know what he is doing.

Hi Nanhai,

while I do agree that perhaps these checks are a little verbose I don't
agree that they are uneccessary. Specifying the base address is entirely
sane on some platforms (e.g. Tiger 2). And more to the point, it is the
only method available on some architectures, and thus its seems
reasonable to expect that it might work sanley on ia64. It seems to me
that it is a good idea to have some checks in place, in line with the
checks performed when the base address is automatically determinted to
make the behaviour (more) consistent. 

Ideally it would be good if there were not two code-paths relating
to base address selection - auto and manual. Or more to the point, if
they could share the same checks. But at this point I can't see a way to
make the code do that.

I guess in the end it comes down to how easy you want it to be for users
mistakes to be caught. I think that currently kexec/kdump is quite
fragile and its easy to end up with a setup that doesn't work. I think
that changes like this one are one small step towards making a more
robust system. Ditto for the change regarding loging success or failure
of inserting the crashkernel region.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

