From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Wed, 14 Jan 2004 10:42:35 +0000
Subject: Yet another MCA handler
Message-Id: <40051D1B.7912DB91@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the season of the MCA handlers :-)
Let me show you the one that Christian Cotte-Barrot and I wrote...

I'd like to take this opportunity to express our special thanks to Jenna
Hall, she gave us the initial version of the ".S" code and much help,
and also to Mani Ayyar, David Song and Tony Luck for the technical
consultations.

Our handler currently deals with the translation register errors only.
I was to write the code for the recovery for poisoned memory, too,
but I've got no way to provoke this kind of error
( I do not really know what it like is :-) )

The key features of our MCA handler are:

* Everything is CPU local ( an MCA data area is allocated and hooked
  to each "cpuinfo" structure )

* No locks

* No rendezvous
 - Does not seem to work if not all the CPUs are started up,
   i.e. you specify a "maxcpus=<NUM>"...
 - A failed rendezvous is a bad omen to start with
 - The correctable / recoverable MCAs are CPU local businesses
 - All the CPUs can handle MCAs simultaneously

* The translation registers are purged / reloaded unconditionally:
  cheaper than calling SAL_GET_STATE_INFO(MCA)

* Table driven TR purging / reload (except for the kernel stack mapping)

* TRs are all purged before the reloading starts ( an erroneous TR can still
  be in conflict with a freshly purged / reloaded one )

* SAL_CLEAR_STATE_INFO(MCA) is called only for MCAs which have been
  corrected (TR errors). For the others, the recovery will be tempted by
  a fake page fault handler, by the device drivers and by the MCA daemon,
  therefore the SAL MCA log is not cleared here -- future extension :-)

* "Silent" MCA handler: no prints by default ( unless debugging )
  - Output uses locks...

* A bit more serious error / status checking

This patch is against the version 2.6.1 + kdb-v4.3-2.6.1-common-b0.bz2 +
kdb-v4.3-2.6.1-ia64-b0.bz2.

Testing:
- Obviously by use of an ITP
- In my next mail I'll include a patch that can insert an illegal
  translation in a TR provoking an MCA

Problems:
Neither "IA64_LOG_NEXT_BUFFER()" nor "salinfo_log_wakeup()" works :-(
I think some addresses are messed up. The system says it cannot
translate virtual address...

I'll send the patch in the next letter.
Should the list refuse it due to its length, please pick it up at our
anonymous FTP server: ftp://visibull.frec.bull.fr/pub/linux/mca/ 

Your remarks will be appreciated.

Zoltan Menyhart
