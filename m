From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Wed, 27 Aug 2008 09:51:13 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <4104961b0808270251n1e7250dbn656ae77d2f8bc3d3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
	<20080827112728.51024582@halley.suse.de>
In-Reply-To: <20080827112728.51024582@halley.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

On Wed, Aug 27, 2008 at 5:27 PM, Bernhard Walle <bwalle@suse.de> wrote:
> Hi Jidong,
>
> * jidong xiao [2008-08-27 17:01]:
>>
>> I encountered the zero-size-vmcore issue on IA64. I remember last year
>> Nanhai submitted a patch which was intended to fix this issue, and I
>> noticed that patch is merged into mainline kernel. I am using
>> 2.6.27-rc2, which means that patch is included in my kernel.And after
>> the system
>> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
>> me know if I need to provide more information.Thanks.
>
> Which version of kexec-tools do you use?
>
Well I am using SLES10SP2,(I tried the experiments on SLES10SP2
default kernel and also 2.6.27-rc2 mainline kernel, result is the
same.)
lfg-ia64:/var/log # rpm -qa | grep kexec
kexec-tools-1.101-32.48
lfg-ia64:/var/log # rpm -qa | grep kdump
kdump-0.3.0-8.9
yast2-kdump-2.13.11-0.3

> Please always include the kexec list (kexec@lists.infradead.org) on
> kdump and kexec issues. I Cc'd it now.
Okay, I see. Thanks.

Regards
Jason Xiao
>
> Bernhard
> --
> Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
>
