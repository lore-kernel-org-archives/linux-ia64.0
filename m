From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 15:19:08 +0000
Subject: Re: [ia64 R&D] CONFIG_IA64_MCA
Message-Id: <200405040819.08506.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
In-Reply-To: <EFC4A8BDEDB4B846BC47F0ED773E812C0734C47C@xsun09.ptp.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 6:53 am, Luck, Tony wrote:
> John> Hi, I have heard rumors that the CONFIG_IA64_MCA option may be
> John> phased out. If this is true, this email is an attempt to lobby
> John> AGAINST such a move.  I work with a team that explicitly
> John> disables the CONFIG_IA64_MCA so that the kernel will NOT
> John> handle MCAs. If kernel handling of MCAs is made automatic,
> John> then that would interfere with our use of the
> John> kernel. Hopefully, this rumor is false.
>
> Would a boot option to skip registration linux handlers with
> SAL work for you?  That would allow us to keep Jesse's cleanup
> that removes a bunch of #ifdefs.

That seems like an even better option, since it means they wouldn't have to 
recompile their kernel (unless they're making other changes), and may be 
useful in general.

Jesse
