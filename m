From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 27 Jun 2001 17:12:48 +0000
Subject: [Linux-ia64] Mylex RAID stability on IA-64
Message-Id: <marc-linux-ia64-105590693005784@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anybody made stress tests on a Mylex RAID controller with Linux/IA64
yet?

We have seen the following phenomena:

1) Syslog messages like

Jun 27 19:02:03 tl02 kernel: DAC960#0: Error Condition VENDOR-SPECIFIC on WRITE:
Jun 27 19:02:03 tl02 kernel: DAC960#0:   /dev/dac960/host0/disc1:
       absolute blocks 23366555..23366562
Jun 27 19:02:03 tl02 kernel: DAC960#0:   /dev/dac960/host0/disc1:
       relative blocks 2..2883680

The error conditions is always "VENDOR-SPECIFIC on WRITE", which doesn't
tell me very much.

2) Random lockups of the IO-intensive commands (cp, tar, find, ...)
This happens rarely, but it does happen. The commands seem to lock up in
wait4() system calls while other commands are still happily doing
I/O.

3) Machine lockups.
This has happened twice, but not yet with the 2.4.5 kernel. Even in the
other cases we cannot be 100% sure that the Mylex I/O "killed" the
machines. The only clue we have is that a message like the one above was
the last record in the syslog before dying.

"I/O stress" means about 4 IO-intensive processes at the same time.

What have other people experienced with these boards on IA-64?

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




