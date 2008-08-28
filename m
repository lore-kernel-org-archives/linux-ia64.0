From: "jidong xiao" <jidong.xiao@gmail.com>
Date: Thu, 28 Aug 2008 04:55:40 +0000
Subject: Re: Zero size vmcore on ia64
Message-Id: <4104961b0808272155s3b092fd6u697d63ba76dd3146@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
In-Reply-To: <4104961b0808270201i64b1914ame2e6e90d316c6c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 28, 2008 at 1:07 AM, Jay Lan <jlan@sgi.com> wrote:
> jidong xiao wrote:
>> Hi, All,
>>
>> I encountered the zero-size-vmcore issue on IA64. I remember last year
>> Nanhai submitted a patch which was intended to fix this issue, and I
>> noticed that patch is merged into mainline kernel. I am using
>> 2.6.27-rc2, which means that patch is included in my kernel.And after
>> the system
>> completed rebooting, there is nothing generated in KDUMP_SAVEDIR. Let
>> me know if I need to provide more information.Thanks.
>
> Which version of kexec were you using? The mismatch between kernel and
> kexec has caused me zero-size-vmcore problem. I need to switch kexec
> when i boot up a more recent upstream kernel or a sles10/rhel5 kernel.
>
Aha, good news, finally I successfully achieved kdump on 2.6.27-rc2.
The only change is I replaced sles10sp2-ia64 default kexec-tools with
kexec-tools 2.0.0 according to Bernhard's advice.

lfg-ia64:~ # ls -l /proc/vmcore
-r-------- 1 root root 4026595264 2008-08-28 11:53 /proc/vmcore
lfg-ia64:~ # ls -l /var/log/dump/2008-08-28-11\:06/
total 3786128
-r-------- 1 root root 4026595264 2008-08-28 11:07 vmcore
lfg-ia64:~ # du -h /var/log/dump/2008-08-28-11\:06/
3.7G    /var/log/dump/2008-08-28-11:06/
lfg-ia64:~ # file /var/log/dump/2008-08-28-11\:06/vmcore
/var/log/dump/2008-08-28-11:06/vmcore: ELF 64-bit LSB core file IA-64
(Intel 64 bit architecture), version 1 (SYSV), SVR4-style
lfg-ia64:~ #

Thank you all.

Jay,
I also tested it with your kdb patches applied.i.e, test kdump command
from inside kdb. The result is fine. overall, the experiments I did
includes ia64 and i386, both are okay.

Regards
Jason

> Regards,
>  - jay
>
>>
>> Regards
>> Jason
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
