From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 13 Dec 2003 09:11:13 +0000
Subject: Re: [jakub@redhat.com: Re: [brian.j.vandecoevering@intel.com: RE: [Linux-ia64] problems with ppp/ppp
Message-Id: <marc-linux-ia64-107130670923227@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107124350029067@msgid-missing>
In-Reply-To: <marc-linux-ia64-107124350029067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Dec 2003 10:37:16 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> Back long ago, I reported a problem with PPP on ia64:
  Bill> http://www.gelato.unsw.edu.au/linux-ia64/0105/1641.html

  Bill> We added the workaround in our tree for earlier releases, and
  Bill> promptly forgot about it; however, someone reported that RHEL
  Bill> 3 has the same issue (as we took the workaround out.)

  Bill> Jakub noticed the following - does this explain the problem?

OK, I fixed this now for 2.6:

  http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1504

That file really needed some cleanup.  Apart from fixing this
particular issue, I also consolidated the GCC vs. Intel macros so they
make more sense and so there is much less code-duplication.

Also, I did a fairly careful analysis of the impact of this bug.
Basically, I built a kernel with "allyesconfig" and tweaked the
uaccess macros to emit their arguments to a special string section,
which I then examined for function calls.  Since the inspection was
manual and there are _tons_ of get_user/put_user calls in the kernel,
it's possible I missed a few function calls, but it shouldn't be off
too far.  Fortunately, the result is that only 28 (out of hundreds) of
get_user/put_user invocations have real (non-inlined) function-calls
in their arguments, 18 are for PPP, 1 for PCMCIA (not an issue for
ia64), 4 for the OSS sound driver and 3 for some watchdog timers which
most likely are not supported on ia64 anyhow.  read_port() in the
/dev/mem driver also has this problem, but this function is defined
only if CONFIG_ISA is on, so we're OK.  The only new issue that came
to light is that the TIOCOUTQ ioctl also has this problem, so I'd
expect spurious failures for that ioctl().

In summary, only PPP and TIOCOUTQ seem to have been affected by this
bug, which probably explains why the bug remained in hiding for so
long.

Anyhow, I included a summary of the problematic calls below for
reference.

	--david

drivers/char/mem.c:321:__put_user: inb(i)
drivers/char/tty_ioctl.c:465:put_user: tty->driver->chars_in_buffer ? tty->driver->chars_in_buffer(tty) : 0
drivers/char/watchdog/wdt.c:342:put_user: wdt_status()
drivers/char/watchdog/wdt.c:342:put_user: wdt_status()
drivers/char/watchdog/wdt_pci.c:327:put_user: wdtpci_status()
drivers/net/ppp_async.c:264:put_user: ppp_channel_index(&ap->chan)
drivers/net/ppp_async.c:264:put_user: ppp_channel_index(&ap->chan)
drivers/net/ppp_async.c:274:put_user: ppp_unit_number(&ap->chan)
drivers/net/ppp_async.c:274:put_user: ppp_unit_number(&ap->chan)
drivers/net/ppp_synctty.c:317:put_user: ppp_channel_index(&ap->chan)
drivers/net/ppp_synctty.c:317:put_user: ppp_channel_index(&ap->chan)
drivers/net/ppp_synctty.c:327:put_user: ppp_unit_number(&ap->chan)
drivers/net/ppp_synctty.c:327:put_user: ppp_unit_number(&ap->chan)
drivers/pcmcia/ds.c:589:put_user: get_queued_event(user)
net/atm/pppoatm.c:338:put_user: ppp_channel_index(&atmvcc_to_pvcc(atmvcc)-> chan)
net/atm/pppoatm.c:338:put_user: ppp_channel_index(&atmvcc_to_pvcc(atmvcc)-> chan)
net/atm/pppoatm.c:341:put_user: ppp_unit_number(&atmvcc_to_pvcc(atmvcc)-> chan)
net/atm/pppoatm.c:341:put_user: ppp_unit_number(&atmvcc_to_pvcc(atmvcc)-> chan)
net/irda/irnet/irnet_ppp.c:668:put_user: ppp_channel_index(&ap->chan)
net/irda/irnet/irnet_ppp.c:668:put_user: ppp_channel_index(&ap->chan)
net/irda/irnet/irnet_ppp.c:668:put_user: ppp_channel_index(&ap->chan)
net/irda/irnet/irnet_ppp.c:676:put_user: ppp_unit_number(&ap->chan)
net/irda/irnet/irnet_ppp.c:676:put_user: ppp_unit_number(&ap->chan)
net/irda/irnet/irnet_ppp.c:676:put_user: ppp_unit_number(&ap->chan)
sound/core/seq/oss/seq_oss_ioctl.c:89:put_user: snd_seq_oss_writeq_get_free_size(dp->writeq)
sound/core/seq/oss/seq_oss_ioctl.c:89:put_user: snd_seq_oss_writeq_get_free_size(dp->writeq)
sound/core/seq/oss/seq_oss_ioctl.c:89:put_user: snd_seq_oss_writeq_get_free_size(dp->writeq)
sound/core/seq/oss/seq_oss_ioctl.c:89:put_user: snd_seq_oss_writeq_get_free_size(dp->writeq)
