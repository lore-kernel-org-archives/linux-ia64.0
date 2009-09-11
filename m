From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 11 Sep 2009 11:15:08 +0000
Subject: Re: elilo questions
Message-Id: <873a6tka0z.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <e75d22a90909101125y26dcd5cdob8f374e2dc160536@mail.gmail.com>
In-Reply-To: <e75d22a90909101125y26dcd5cdob8f374e2dc160536@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Michael" = Michael Di Domenico <mdidomenico4@gmail.com> writes:

Michael> Hopefully someone here can either help or point me in the
Michael> right direction.  I've gotten an IA64 system (hp rx2600) to
Michael> boot via PXE(elilo) and install RedHat v5.3, but I've run
Michael> into a few issues:

Michael> 1.  When i try to use a kickstart line with an ampersand in
Michael> it, for some reason the ampersand's don't seem to make it
Michael> through to the HTTP server, for example


Not sure on this one, but I think that ampsersands are special in
HTML, and need to be protected: try using &amp; instead.



Michael> 2.  I'd like to setup the machines to boot from network
Michael> everytime, via DHCP

Michael> 2a.  first issue, after i do a kickstart install it resets
Michael> the systems EFI firmware to boot from the hard disk by
Michael> default rather then the network card, is there a way to force
Michael> it to always boot from the nic first regardless or prevent
Michael> something from changing the settings

Once you've done the installation, you can adjust the boot order from
the console.  There may be a way of adjusting this in your golden
image too.

Michael> 2b.  i can't seem to get the system to boot off the HDD after
Michael> booting from the network.  i want the system to boot off the
Michael> network first and then if no commands are entered, i want it
Michael> to boot from the hard drive.  with PXE, it has a 'localboot'
Michael> option which falls through if no input is entered

Again, this should be possible by adjusting the boot order and
priority in the console before invoking EFI.  I'm not in front of a
machine at present, so can't check what the options are (sorry).

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
