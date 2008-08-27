From: Jay Lan <jlan@sgi.com>
Date: Wed, 27 Aug 2008 17:07:55 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <48B589EB.7030307@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
In-Reply-To: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

jidong xiao wrote:
> Hi, All,
> 
> I encountered the zero-size-vmcore issue on IA64. I remember last year
> Nanhai submitted a patch which was intended to fix this issue, and I
> noticed that patch is merged into mainline kernel. I am using
> 2.6.27-rc2, which means that patch is included in my kernel.And after
> the system
> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
> me know if I need to provide more information.Thanks.

Which version of kexec were you using? The mismatch between kernel and
kexec has caused me zero-size-vmcore problem. I need to switch kexec
when i boot up a more recent upstream kernel or a sles10/rhel5 kernel.

Regards,
 - jay

> 
> Regards
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

