From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 03:46:29 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070307034627.GB29334@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 07, 2007 at 10:15:20AM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: Horms [mailto:horms@verge.net.au]
> > Sent: 2007年3月7日 8:50
> > To: Zou, Nanhai
> > Cc: Linux-IA64; fastboot@lists.osdl.org; Luck, Tony; Magnus Damm
> > Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
> > 
> > On Tue, Mar 06, 2007 at 04:23:37PM +0800, Zou, Nanhai wrote:
> > >
> > > Hi Horms,
> > > 	I feel this is over-designed.
> > >      I think to specify crash kernel base address in command line is only
> > useful for debug, on platform like SN this feature is totally unusable.At the
> > most of time, user should let kernel to decide where to reserve crashdump
> > region.
> > >     If a user wants to put crash kernel in command line, he should know what
> > he is doing.
> > 
> > Hi Nanhai,
> > 
> > while I do agree that perhaps these checks are a little verbose I don't
> > agree that they are uneccessary. Specifying the base address is entirely
> > sane on some platforms (e.g. Tiger 2). And more to the point, it is the
> > only method available on some architectures, and thus its seems
> > reasonable to expect that it might work sanley on ia64. It seems to me
> > that it is a good idea to have some checks in place, in line with the
> > checks performed when the base address is automatically determinted to
> > make the behaviour (more) consistent.
> > 
> > Ideally it would be good if there were not two code-paths relating
> > to base address selection - auto and manual. Or more to the point, if
> > they could share the same checks. But at this point I can't see a way to
> > make the code do that.
> > 
> > I guess in the end it comes down to how easy you want it to be for users
> > mistakes to be caught. I think that currently kexec/kdump is quite
> > fragile and its easy to end up with a setup that doesn't work. I think
> > that changes like this one are one small step towards making a more
> > robust system. Ditto for the change regarding loging success or failure
> > of inserting the crashkernel region.
> > 
> Hi,
> 	I think even in the situation of manually pick address, user can check /proc/iomem to found the address, it is easy.
>      I don't see in which situation like kernel automatically determined method does not work but manually pick address would work. So I think manually pick address could only be help for debug. But I think it is good to have this feature since it only cost 2 lines of code.
>     I believe it is good to keep the kernel code simple and clean. 
> We do not need to add more than 70 lines of code to kernel only for debug print.
> You can add those prints to kernel whenever you want to debug something, but put those in vanilla kernel is not a good idea.
>   BTW: the code logic in your updated patch is still not correct, in kdump_region_verify_rsvd_region you do not check the partly overlap situation.

I think that the manual option is also important because it maintains
feature-compatibility with other architectures. I don't consider it
a hack that might work purely for the purposes of debugging.

With regards to 70 lines of extra code, it can probably be consolidated
a bit - for insance I think that the ckeck contained in
kdump_region_verify_rsvd_region() is more important than the other
checks which I guess could be disposed of if the length of the code
really is a problem. But in any case the new code is almost entirely in
__init. So I don't really see that it is a big concern.

As for the partly-overlaped case in kdump_region_verify_rsvd_region(). 
I'm not entirely sure what you are getting at there. Are you talking
about an optimisation to the check, or a correctness problem?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

