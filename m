From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 15 Jun 2000 18:16:23 +0000
Subject: Re: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205146@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been using USB on my main IA-64 workstation for months now and it
has worked without a hitch.  Both the keyboard and mouse are USB, so
there is no problem there.  The only thing that doesn't seem to be
supported is to "mix" a regular PS/2 and a USB mouse into a single
device (as is the case for the keyboard).  On my machine, /dev/mouse
is a symlink to /dev/input/mousemix and mousemix is the following
special device:

 crw-r--r--   1 root     root      13,  63 Apr 27 17:52 /dev/input/mousemix

That plus the right kernel configuration options and XF86Config file
should be all it takes for a USB mouse to work.

	--david

>>>>> On Thu, 15 Jun 2000 10:47:29 -0700, Johannes Erdfelt <jerdfelt@valinux.com> said:

  Johannes> On Thu, Jun 15, 2000, Eric Wang <ericwang25@hotmail.com>
  Johannes> wrote:
  >> During the machine boot up period, the USB keyboard could not
  >> work, so you should connect both PS/2 and USB Mouse and Keyboard
  >> on the machine. After boot up, install TurboLinux build 5.5 (May
  >> 5?), it will install the USB keyboard driver. After the
  >> installation, start the Turbolinux OS, startx, you will see the
  >> USB keyboard is active. But the USB mouse could not work.

  Johannes> "Could not work" is pretty strong language. I don't see
  Johannes> any reason why it could not work. Perhaps it's not just
  Johannes> not implemented now?

  Johannes> I know X can work with a USB mouse, but it needs to be
  Johannes> configured properly, including the appropriate device
  Johannes> nodes being created.

  Johannes> JE



  Johannes> _______________________________________________ Linux-IA64
  Johannes> mailing list Linux-IA64@linuxia64.org
  Johannes> http://lists.linuxia64.org/lists/listinfo/linux-ia64


