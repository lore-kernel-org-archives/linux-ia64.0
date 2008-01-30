From: Olof Johansson <olof@lixom.net>
Date: Wed, 30 Jan 2008 21:39:26 +0000
Subject: Re: [powerpc changes] Re: x86/non-x86: percpu, node ids, apic ids
Message-Id: <20080130213926.GA22841@lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <20080130184920.GA32212@elte.hu> <20080130191302.GA20008@lixom.net> <20080130212558.GA12409@elte.hu>
In-Reply-To: <20080130212558.GA12409@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Paul Mackerras <paulus@samba.org>, anton@samba.org, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, "Luck, Tony" <tony.luck@intel.com>, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Linux Kernel Development <linux-kernel@vger.kernel.org>, Mike Travis <travis@sgi.com>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Jan 30, 2008 at 10:25:58PM +0100, Ingo Molnar wrote:
> 
> * Olof Johansson <olof@lixom.net> wrote:
> 
> > > could you try the full patchset that Travis has just sent and which 
> > > i've put into x86.git, you can pull it from:
> > 
> > Looks ok for powerpc so far, I haven't gotten through all defconfigs 
> > yet but the first ones that failed before build now. pasemi_defconfig 
> > boots as well.
> 
> could the PowerPC maintainers please Ack the following patch (attached 
> below):
> 
>   Subject: POWERPC: use generic per cpu
>   From: travis@sgi.com
> 
> so that we can push this fix upstream ASAP?

> Subject: POWERPC: use generic per cpu
> From: travis@sgi.com
> 
> Powerpc has a way to determine the address of the per cpu area of the
> currently executing processor via the paca and the array of per cpu
> offsets is avoided by looking up the per cpu area from the remote
> paca's (copying x86_64).
> 
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
> Signed-off-by: Mike Travis <travis@sgi.com>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>

Paul is at LCA, I'm not sure if he's reading email. Looks good to me so:

Acked-by: Olof Johansson <olof@lixom.net>


-Olof
