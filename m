From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 07 Nov 2000 22:10:13 +0000
Subject: Re: [Linux-ia64] Performance Monitor Internals:
Message-Id: <marc-linux-ia64-105590678205662@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> 
>     My colleague and I are working with the IA64 performance monitors
> and would like to get involved
>     or at least learn more about the development effort of the syscall
> interface and its internals. Has
>     any person or group been assigned to this task? If so, please email
> me or the list so we can
>     possibly collaborate on the design/implementation effort.
> 

I am currently working on the perfmon support for Linux/ia64 as you may
have seen for the recent patches.  The goal is to support the entire set
of features of the Itanium PMU including EARS and BTB and not just counting.
Also support is planned for per process AND system-wide monitoring on
both UP and SMP systems.

So I you have any ideas, concerns or want to contribute something, please
feel free to contact me.

Regards,

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

