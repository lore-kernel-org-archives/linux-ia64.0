From: "Leonard N. Zubkoff" <lnz@dandelion.com>
Date: Fri, 10 Aug 2001 16:20:09 +0000
Subject: [Linux-ia64] Re: Mylex RAID & IA64 - processes sleeping in wait_on_buffer()/down()
Message-Id: <marc-linux-ia64-105590698805056@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Date: Fri, 10 Aug 2001 15:36:07 +0200 (CEST)
  From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>

  Hi Leonard, all,

  I have run some more tests and have better debugging tools available
  now (among other things, a Mylex debugging cable). I made two tests
  yesterday and today with similar outcomes.

Which kernel are you using?  2.4.7 introduced a new "completion" mechanism to
avoid races in the semaphore code formerly being used, and we found some
serious VM cleaning problems that could cause system hangs this past few days.
I believe the latest 2.4.8 pre-release kernel should be more reliable in this
regard.

  Yesterday for the first time ever I saw no driver error message before
  the problems (hanging I/O) occured. Today a "NO SENSE ON WRITE" message
  was issued approx. 15 minutes before the test came to a halt.

  The serial console (debugging cable) showed the message
  "UnimplCmd 0pc0H IqpC1H".

Are you in contact with Mylex regarding these problems?  If the controller is
dropping a command on the floor due to its being invalid, and never completing
it, that could be cause for hanging such as you report.

  Here is the list of uninterruptibly sleeeping processes after the test
  stopped (today's test):

  $ ps -eo fname,pid,ppid,stat,state,nwchan,wchan | grep '\<D\>'
  rm        3023  1136 D    D 4fa710 wait_on_buffer
  rm        3036  1140 D    D 4fa710 wait_on_buffer
  cp        3055  3054 D    D 45fc90 down
  cp        3070  3069 D    D 45fc90 down
  rm        3075  1139 D    D 45fc90 down
  cp        3096  3095 D    D 45fc90 down

  The stack trace for both processes 3023 and 3036 is
  __wait_on_buffer - [lock_buffer] - unmap_buffer - block_flushpage -
  truncate_list_pages - truncate_inode_pages - iput - d_delete - vfs_unlink
  - sys_unlink.

  Obviously these processes wait forever for a buffer head to get unlocked.

  The other processes sleep on a the semaphore of the indode of an dentry
  (dentry->d_inode->i_sem). These semaphores are most likely blocked by
  either PID 3023 or 3036.

  Upon further inquiry into the DAC960 code, I found that the driver uses
  virt_to_bus() to get DMA addresses, which is deprecated on 64 bit
  architectures (comments in asm-ia64/io.h recommend to use
  pci_map_single()/pci_unmap_single() instead).

Interesting.  Well, deprecated means that one should move away from using it,
which I planned to do once 2.4 was stable enough for more serious use, but it
should still work correctly, and if it does not I consider that a bug.

  I suspect that this may have
  something to do with the problems we are encountering, although
  pci_map_single() basically calls virt_to_phys() if a controller is
  capable of 64 bit addressing. A difference can be seen in
  pci_unmap_single(), where the buffer pages are marked clean after the DMA
  is processed. Although it makes not much sense that this should cause
  problems as those described above, it is at least a starting point.
  It would be interesting to know in this regard if it is planned to use the
  pci map interface for the DAC960 driver in the not-so-far future.

Yes, I do plan to move to the pci_map/unmap_single interface before too long,
but in the meanwhile the virt_to_bus interface should work.  If not, it needs
to be declared obsolete and removed, rather than being labelled deprecated.

I believe in a previous message I speculated that DMA or bus problems could
make some of the data structures look invalid, so perhaps that is occurring
here.

		Leonard

