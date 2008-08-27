From: Bernhard Walle <bwalle@suse.de>
Date: Wed, 27 Aug 2008 11:24:19 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <20080827132419.6b77f01c@halley.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
	<20080827112728.51024582@halley.suse.de>
	<4104961b0808270251n1e7250dbn656ae77d2f8bc3d3@mail.gmail.com>
	<20080827121443.396d8bac@halley.suse.de>
	<4104961b0808270354y267145e7l637b70ee4c8a384a@mail.gmail.com>
In-Reply-To: <4104961b0808270354y267145e7l637b70ee4c8a384a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jidong xiao <jidong.xiao@gmail.com>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

* jidong xiao [2008-08-27 18:54]:
> >
> > With the SP2 default kernel, it should work. At lest /proc/vmcore
> > should have a normal size. Can you set KDUMP_IMMEDIATE_REBOOT to "no",
> > then log in in the serial console and execute
> >
> >        # ls -l /proc/vmcore
> I am sorry to say, I tried to follow your instruction but finally the
> out put is zero.
> lfg-ia64:~ # ls -l /proc/vmcore
> -r-------- 1 root root 0 2008-08-27 18:40 /proc/vmcore

Strange. Which hardware is that?


Bernhard
-- 
Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
