From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 17 Oct 2007 03:35:05 +0000
Subject: Re: [PATCH 9/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <87ejfuxvkm.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BF9C.6090308@jp.fujitsu.com>
In-Reply-To: <4714BF9C.6090308@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Hidetoshi" = Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:

>> [9/9] ia64_acct_get_vtime.patch
Hidetoshi> Now all check points are ready.

Hidetoshi> We already cumulate cycles for stime/utime on kernel
Hidetoshi> entrance/exit, so what we need to do is reflecting them
Hidetoshi> into stime/utime of the thread, after translating cycles to
Hidetoshi> nsec.

This patchset duplicates some of the Microstate Accounting patchset
(which attempts to keep track of time spent in various states for each
thread).  As such I've had some experience trying to do this stuff.
  Things to watch are:
 -- With Montvale and later, the processor clock speed can be
    varied via ACPI.  Does ITC rate change?  In additon, KVM can
    virtualise ITC (although it doesn't at present)
 -- ITC is not synchronised across multiple processors.  I don't think
    this'll be an issue for you as you're only measuring time on-cpu,
    and migration necessarily goes via a run queue.
 -- Adding ACCOUNT_SYS_ENTER adds around 40 cycles to the system
    call path.  If you wanted, you could move reading ITC earlier (it
    takes up to 36 cycles), and overlap with other work.

Peter C
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
