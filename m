From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 30 Jul 2001 21:25:09 +0000
Subject: Re: [Linux-ia64] Matrox G400 DRI doesn't work w/ Linux/ia64 2.4.5
Message-Id: <marc-linux-ia64-105590693005952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005951@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005951@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just an additional data point: DRI works fine on 2.4.5 with the 3dfx
card.  The card doesn't use AGP though.

	--david

>>>>> On Mon, 30 Jul 2001 15:13:48 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> I'm running RedHat 7.1 on an HP i2000 ia64 box with a Matrox
  Bjorn> G400.  This has kernel 2.4.3 (with RedHat's patches) and
  Bjorn> XFree86 4.0.3.

  Bjorn> DRI seems to work fine as far as I can tell (glxinfo says
  Bjorn> "Mesa DRI G400", gears reports ~36 fps with "dri" and "glx"
  Bjorn> loaded, ~28 fps without).

  Bjorn> However, DRI doesn't work with a 2.4.5 kernel.  The kernel
  Bjorn> boots fine, and X starts up fine, and glxinfo again says
  Bjorn> "Mesa DRI G400", but gears opens a window with nothing in it.
  Bjorn> After starting gears, I can move the mouse pointer, but X
  Bjorn> seems dead.  The screen looks fine (with the empty gears
  Bjorn> window), but no mouse events work and I can't kill the
  Bjorn> server.

  Bjorn> I've applied RedHat's agp kernel patches to my 2.4.5 kernel,
  Bjorn> so drivers/char/agp and drivers/char/drm are identical
  Bjorn> between the working 2.4.3 and the broken 2.4.5 trees.

  Bjorn> Bjorn

  Bjorn> _______________________________________________ Linux-IA64
  Bjorn> mailing list Linux-IA64@linuxia64.org
  Bjorn> http://lists.linuxia64.org/lists/listinfo/linux-ia64

