From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 23:55:29 +0000
Subject: Re: [Linux-ia64] Strange ACPI interruptions in 2.5.45 kernel
Message-Id: <marc-linux-ia64-105590709805605@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 16:21:46 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:

  Joel> I'm working on a Lion machine (with 2 processors Itanium I)
  Joel> running a 2.5.45 kernel, and I've got thousands of
  Joel> interruptions routed throw ACPI.

  Joel> I use PS/2 mouse and keyboard.  I've seen there were lots of
  Joel> problems with PS/2 on 2.5-ia64 kernels but I didn't see anyone
  Joel> who had this one.

  Joel> When I say "lots" of interruptions, I mean about 80 times more
  Joel> than the timer ticks !!!! So, one of my processor spend almost
  Joel> all his time dealing with ACPI interruptions .

  Joel> Just to have a look, I've tried to disable ACPI interruptions
  Joel> after the boot. ...and now, the interruptions are reported via
  Joel> one of the serial irq (according to the /proc/interrupts).. if
  Joel> it can help.

  Joel> I had no problems with this interruptions in the 2.5.44 kernel
  Joel> or previous versions. I searched the code to see what had
  Joel> changed between the 2 kernels, but I couldn't find any
  Joel> interesting explanation.  BUT I already had problems since the
  Joel> 2.5 kernels(like a lot of people) with my mouse or/and my
  Joel> keyboard (with i8042).

  Joel> So if you have any idea...?

That doesn't ring a bell.  I suppose you could try 2.5.50.  I don't
use the Lion's for kernel development very often myself anymore
because they're diffiult and slow to remote-reboot.  Perhaps someone
else can help.

	--david


