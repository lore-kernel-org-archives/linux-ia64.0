From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 24 Jul 2001 12:58:14 +0000
Subject: [Linux-ia64] DAC960 on IA/64
Message-Id: <marc-linux-ia64-105590693005896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Leonard,

I have made a very small step forward in debugging the problems.
After reading this message from Linux to the LK mailinglist
<http://www.uwsg.indiana.edu/hypermail/linux/kernel/0107.2/0533.html>
I suspected that SMP may have something to do with it.

So I repeated our test with the stock RedHat UP kernel (2.4.3),
and with much less catastrophic results. I got no more hanging
processes, no system crash, "just" some data errors that suggest
that 18 512-byte blocks in a 2GB file were pointing at a wrong disk
area (there were valid bit patterns there, but patterns that should
appear elsewhere in the file).

This may look like a VFS or ext2-related problem, but similar tests
on other controllers have revealed nothing of the kind.

Interestingly, the driver also reported
no "vendor-specific" or other errors during the test.

I cannot exclude 100% that this test went better than the previous
tests simply by "luck", but it seems unlikely, because the system
survived 12 hours of heavy copy-compare whereas it always showed
uninterruptibly sleeping processes or even total crashes after
ca. 5 hours with SMP.

Hope that helps a bit, regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




