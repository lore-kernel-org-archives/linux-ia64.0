From: Bernhard Walle <bwalle@suse.de>
Date: Wed, 27 Aug 2008 09:27:28 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <20080827112728.51024582@halley.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
In-Reply-To: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jidong xiao <jidong.xiao@gmail.com>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

Hi Jidong,

* jidong xiao [2008-08-27 17:01]:
> 
> I encountered the zero-size-vmcore issue on IA64. I remember last year
> Nanhai submitted a patch which was intended to fix this issue, and I
> noticed that patch is merged into mainline kernel. I am using
> 2.6.27-rc2, which means that patch is included in my kernel.And after
> the system
> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
> me know if I need to provide more information.Thanks.

Which version of kexec-tools do you use?

Please always include the kexec list (kexec@lists.infradead.org) on
kdump and kexec issues. I Cc'd it now.


Bernhard
-- 
Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
