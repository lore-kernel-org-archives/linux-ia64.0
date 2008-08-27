From: Bernhard Walle <bwalle@suse.de>
Date: Wed, 27 Aug 2008 10:14:43 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <20080827121443.396d8bac@halley.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
	<20080827112728.51024582@halley.suse.de>
	<4104961b0808270251n1e7250dbn656ae77d2f8bc3d3@mail.gmail.com>
In-Reply-To: <4104961b0808270251n1e7250dbn656ae77d2f8bc3d3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jidong xiao <jidong.xiao@gmail.com>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

* jidong xiao [2008-08-27 17:51]:
>
> On Wed, Aug 27, 2008 at 5:27 PM, Bernhard Walle <bwalle@suse.de> wrote:
> > Hi Jidong,
> >
> > * jidong xiao [2008-08-27 17:01]:
> >>
> >> I encountered the zero-size-vmcore issue on IA64. I remember last year
> >> Nanhai submitted a patch which was intended to fix this issue, and I
> >> noticed that patch is merged into mainline kernel. I am using
> >> 2.6.27-rc2, which means that patch is included in my kernel.And after
> >> the system
> >> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
> >> me know if I need to provide more information.Thanks.
> >
> > Which version of kexec-tools do you use?
> >
> Well I am using SLES10SP2,(I tried the experiments on SLES10SP2
> default kernel and also 2.6.27-rc2 mainline kernel, result is the
> same.)

With the SP2 default kernel, it should work. At lest /proc/vmcore
should have a normal size. Can you set KDUMP_IMMEDIATE_REBOOT to "no",
then log in in the serial console and execute

	# ls -l /proc/vmcore

For 2.6.27 kernel on IA64, you have to update kexec-tools. I don't know
the exact version when the change was included, but 2.0.0 is safe. :)


Bernhard
-- 
Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
