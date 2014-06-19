From: Hartley Sweeten <HartleyS@visionengravers.com>
Date: Thu, 19 Jun 2014 17:01:39 +0000
Subject: RE: [staging:staging-next 151/175] drivers/staging/comedi/drivers/ni_pcimio.c:1105:42: error: macro 
Message-Id: <DC148C5AA1CEBA4E87973D432B1C2D8825EB031E@P3PWEX4MB008.ex4.secureserver.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140619011400.GB31778@localhost>
In-Reply-To: <20140619011400.GB31778@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, June 18, 2014 6:14 PM, Fengguang Wu wrote:
> On Wed, Jun 18, 2014 at 11:13:13PM +0000, Hartley Sweeten wrote:
>> On Wednesday, June 18, 2014 3:44 PM, kbuild test robot wrote:
>>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git staging-next
>>> head:   98e11370052aa88a38c2d5d1693a5ec2966c4f81
>>> commit: 9c340ac934dbbfd46e776465b08391baac32d486 [151/175] staging: comedi: ni_stc.h: add read/write callbacks to struct ni_private
>>> config: make ARCH=ia64 allmodconfig
>>>
>>> All error/warnings:
>>>
>>>    drivers/staging/comedi/drivers/ni_pcimio.c: In function 'e_series_win_out':
>>> >> drivers/staging/comedi/drivers/ni_pcimio.c:1105:42: error: macro "writew" passed 3 arguments, but takes just 2
>>>    drivers/staging/comedi/drivers/ni_pcimio.c:1105:2: warning: statement with no effect [-Wunused-value]
>> 
>> [snip]
>> 
>>> vim +/writew +1105 drivers/staging/comedi/drivers/ni_pcimio.c
>>>
>>>   1099	static void e_series_win_out(struct comedi_device *dev, uint16_t data, int reg)
>>>   1100	{
>>>   1101		struct ni_private *devpriv = dev->private;
>>>   1102		unsigned long flags;
>>>   1103	
>>>   1104		spin_lock_irqsave(&devpriv->window_lock, flags);
>>> > 1105		devpriv->writew(dev, reg, Window_Address);
>> 
>> I don't get it... Why is the 'writew' above being treated as a macro in your build?
>
>         wfg /c/linux% grep -r writew arch/ia64 
>         arch/ia64/lib/io.c:#undef __ia64_writew
>         arch/ia64/include/asm/io.h:#define __ia64_writew        ___ia64_writew
>         arch/ia64/include/asm/io.h:__writew (unsigned short val, volatile void __iomem *addr)
> =>     arch/ia64/include/asm/io.h:#define writew(v,a)  __writew((v), (a))
>        arch/ia64/include/asm/io.h:#define __raw_writew writew
>
>> I'm not seeing these errors in my build with the x86_64_defconfig.
>
> Hartley, it's an error in ARCH=ia64 builds.

Hmm.. I guess x86 does not use a macro for writew.

I was assuming it used the generic one in:

include/asm-generic/io.h:#define writew(b,addr) __raw_writew(__cpu_to_le16(b),addr)

Regardless, I will be posting some patches to Greg shortly that remove the
callbacks from struct ni_private. That should fix the problem.

Sorry for the trouble,
Hartley


