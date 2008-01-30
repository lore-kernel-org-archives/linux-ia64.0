From: Geoff Levand <geoffrey.levand@am.sony.com>
Date: Wed, 30 Jan 2008 21:18:42 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <47A0E9B2.1010706@am.sony.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org>	<Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>	<47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu>	<1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com>	<20080130180623.GA24881@elte.hu>	<1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <20080130184920.GA32212@elte.hu>
In-Reply-To: <20080130184920.GA32212@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Luck, Tony" <tony.luck@intel.com>, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Linux Kernel Development <linux-kernel@vger.kernel.org>, Mike Travis <travis@sgi.com>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>

Ingo Molnar wrote:
> * Luck, Tony <tony.luck@intel.com> wrote:
> 
>> > Could you check the patch below? With this applied to latest -git, 
>> > ia64 buils fine for me in a cross-compiling environment. (but i dont 
>> > know whether it boots ...)
>> 
>> Uni-processor build still fails with this patch (config is 
>> arch/ia64/configs/tiger_defconfig with CONFIG_SMP switched from =y to 
>> =n).
> 
> could you try the full patchset that Travis has just sent and which i've 
> put into x86.git, you can pull it from:
> 
>     git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
> 
> it's a fixes only tree, ontop of Linus-very-latest. Head 4b9e425c25f84. 
> [pull from ssh://master.kernel.org if it's not on git.kernel.org yet, 
> uploaded it this very minute.]

Just FYI, the following diff from the above tree applied to linux-2.6.git
works with ps3_defconfig on the PS3 (powerpc):

  git diff dd430ca20c40ecccd6954a7efd13d4398f507728..3823daf866c272c670dda7dc6179a647da64467f

-Geoff

