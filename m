From: "Chris McDermott/Beaverton/IBM" <mcdermoc@us.ibm.com>
Date: Wed, 09 Aug 2000 21:58:11 +0000
Subject: Re: [Linux-ia64] Processor Rev.
Message-Id: <marc-linux-ia64-105590678205300@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It happened here on 2 entries: perfmon_info and power_info.

Chris



Stephane Eranian <eranian@frankl.hpl.hp.com>@linuxia64.org on 08/09/2000
02:34:06 PM

Please respond to <eranian@hpl.hp.com>

Sent by:  linux-ia64-admin@linuxia64.org


To:   linux-ia64@linuxia64.org
cc:
Subject:  Re: [Linux-ia64] Processor Rev.



Hi,
>
> [gerrit@elm3a86 palinfo]$ cat /proc/palinfo/version_info
> PAL_vendor     : 0xff (min=0xff)
> PAL_A revision : 0x9 (min=0x9)
> PAL_A model    : 0x22 (min=0x22)
> PAL_B mode     : 0x9 (min=0x0)
> PAL_B revision : 0x22 (min=0x0)
>
> There is other stuff of interest in /proc/palinfo.
>
> Chris pointed out that the minor numbers of the version aren't included
here.

In the latest kernel patch the output is slightly different. Here the minor
number is .9. So 0x22 0x9 is read 2.2.9 for PAL version.

>
> Also, reading one of the files here caused a panic with the B1 CPU
steppings.
>
Yes, I am aware of this problem. I noticed yesterday while trying it out
on our B1. I don't recall exactly which entry it is. I will be checking
for that.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



