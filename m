From: Steffen Persvold <sp@scali.com>
Date: Fri, 26 Apr 2002 02:40:23 +0000
Subject: [Linux-ia64] Strange behaviour
Message-Id: <marc-linux-ia64-105590701905530@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

In our lab we have two B2-stepping BigSur (that is the codename for
the 2-cpu ones isn't it ?) machines running slightly modified RH7.1 2.4.3
kernel with SMP support (Yes I know, it's unsupported hardware, but
they've worked fine so far). When I do a rather long DMA transfer with a
Dolphin SCI card the machine prints this to the serial console and stops :

gSelFlashStartAddr  :  ffe4ffb0
gSelLogLength       :      ffaf
gSelNextEntry       :      5386
gSelEntryCount      :         9
gSelNewEntriesCount :         1
gSelLastLogRead     :         0
gSelCurMaxRecordSize:      13b0
gSelFlags           :        28
gSelFullFlag        :         0
gSelValidFlag       :         1
gSelClearFlag       :         0
gSelControl         :         0
gFlashExists        :         1
gSelFlashStartAddr  :  ffe4ffb0
gSelLogLength       :      ffaf
gSelNextEntry       :      673c
gSelEntryCount      :         a
gSelNewEntriesCount :         2
gSelLastLogRead     :         0
gSelCurMaxRecordSize:      13b0
gSelFlags           :        28
gSelFullFlag        :         0
gSelValidFlag       :         1
gSelClearFlag       :         0
gSelControl         :         0
gFlashExists        :         1


No kernel oops, no kdb, no nothing. Only solution is to power the server
off and then on again.

I'm curious to what this is, it seems to come from the machine firmware or
something ? Is this related to the beta HW I have, Linux kernel version or
is it something else ?

Thanks in advance,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


