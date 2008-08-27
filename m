From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Wed, 27 Aug 2008 09:16:17 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <4104961b0808270216w3b0d6d55xc89ec24c00050fd7@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
In-Reply-To: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 27, 2008 at 5:01 PM, jidong xiao <jidong.xiao@gmail.com> wrote:
> Hi, All,
>
> I encountered the zero-size-vmcore issue on IA64. I remember last year
> Nanhai submitted a patch which was intended to fix this issue, and I
> noticed that patch is merged into mainline kernel. I am using
> 2.6.27-rc2, which means that patch is included in my kernel.And after
> the system
> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
> me know if I need to provide more information.Thanks.
>
> Regards
> Jason
>

After kdump process finished and the system rebooted, what I can see
in the log file is:
===============
Kernel logging (ksyslog) stopped.
Kernel log daemon terminating.

Boot logging started on /dev/tty1(/dev/console) at Wed Aug 27 15:20:26 2008

Master Resource Control: previous runlevel: N, switching to runlevel: 1
Zero size vmcore
done

INIT: Switching to runlevel: 6



INIT: Sending processes the TERM signal
=================

Regards
Jason
