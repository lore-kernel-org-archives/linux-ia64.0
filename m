From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 26 Jun 2001 13:59:08 +0000
Subject: [Linux-ia64] Help - 2.4.5 SMP doesn't boot (any more)
Message-Id: <marc-linux-ia64-105590693005768@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Yesterday I had 2.4.5 running fine. Since today, I can't boot
the 2.4.5 SMP kernel any more. I get a kernel panic (invalid page
request at 0000000000000010) after SMP is enabled
(actually the last message I see is "trying to unmount old root ...",
but from kdb messages and the fact that uniprocessor 2.4.5 boots, it
is clear that it is a SMP error). The panic happens before syslog
startup, so I can't send a backtrace right now (I do not have
a serial console ready). kdb backtace leaves me in the start_ap
function.

My BIOS has reported "8140 Processor in socket M0 failed FRB level 3
timer" for some time, but that didn't cause problems before and still
doesn't with 2.4.4.

Any ideas?
Thanks,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




