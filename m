From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 30 Jul 2001 21:13:48 +0000
Subject: [Linux-ia64] Matrox G400 DRI doesn't work w/ Linux/ia64 2.4.5
Message-Id: <marc-linux-ia64-105590693005951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm running RedHat 7.1 on an HP i2000 ia64 box with a Matrox G400.  This 
has kernel 2.4.3 (with RedHat's patches) and XFree86 4.0.3.

DRI seems to work fine as far as I can tell (glxinfo says "Mesa DRI G400", 
gears reports ~36 fps with "dri" and "glx" loaded, ~28 fps without).

However, DRI doesn't work with a 2.4.5 kernel.  The kernel boots fine, and 
X starts up fine, and glxinfo again says "Mesa DRI G400", but gears opens 
a window with nothing in it.  After starting gears, I can move the mouse 
pointer, but X seems dead.  The screen looks fine (with the empty gears 
window), but no mouse events work and I can't kill the server.

I've applied RedHat's agp kernel patches to my 2.4.5 kernel, so 
drivers/char/agp and drivers/char/drm are identical between the working 
2.4.3 and the broken 2.4.5 trees.

Bjorn

