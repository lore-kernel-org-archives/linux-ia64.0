From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 17 Jan 2001 01:39:39 +0000
Subject: Re: [Linux-ia64] Errors when compiling kernel (2.4.0test10)
Message-Id: <marc-linux-ia64-105590693005059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005054@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005054@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

All the "errors" you're describing are compiler warnings.  While it
would be nicer to have the kernel build without warnings.  The way we
use the toolchain in the kernel, we err on the side of issuing too
many rather than too few warnings.  Indeed, all the warnings you
mention are spurious in that sense and you don't have to worry about
them.

If the kernel doesn't build for you, there must be something else
that's wrong (beyond the warnings you mentioned).

	--david

>>>>> On Tue, 16 Jan 2001 18:11:14 -0500, "bertos, deborah" <bertos_deborah=
@emc.com> said:

  Deborah> Hi!  I'm hoping someone can help me out.  I've just
  Deborah> installed turbolinux's 1123 release for ia64, and I'm
  Deborah> having trouble compiling the kernel.

  Deborah> I run the following commands: make mrproper make menuconfig
  Deborah> make dep make clean make

  Deborah> When I run make, I start receiving numerous errors, and the
  Deborah> command exits before completing.  I receive the following
  Deborah> error multiple times every time I run make:

  Deborah> /usr/src/linux/include/asm/unistd.h: 287: warning: 'dummy2'
  Deborah> might be used uninitialized in this function.  (this error
  Deborah> shows up with either 287, 288, or 289 as the lines where
  Deborah> the error is occurring, and the error is showing either
  Deborah> dummy2, 3, 4, or 5.)

  Deborah> In addition, I'm receiving several errors on several
  Deborah> different files.  The files and the errors themselves seem
  Deborah> to change each time I try to run through the compilation
  Deborah> process, starting from make mrproper.  Some examples of the
  Deborah> errors are:

  Deborah> pm.c: In function 'pm_send': pm.c:132: warning cast from
  Deborah> pointer to integer of different size.

  Deborah> module.c: In function 'sys_init_module': module.c:365:
  Deborah> warning passing arg 1 of 'kdbaddmodsym' discards qualifiers
  Deborah> from pointer target type.

  Deborah> ivt.S:253: warning: Only the first path encountering the
  Deborah> conflict is reported ivt.S:249: warning: This is the
  Deborah> location of the conflicting usage.

  Deborah> Thanks for the help.


  Deborah> EMC=B2 Deborah Bertos The Enterprise Storage Company Systems
  Deborah> Engineer HA & Systems Integration

  Deborah> EMC Corporation 228 South Street *Office: (508) 435-1000
  Deborah> ext.  23168 Hopkinton, MA 01748 *E-Mail:
  Deborah> bertos_deborah@emc.com



  Deborah> _______________________________________________ Linux-IA64
  Deborah> mailing list Linux-IA64@linuxia64.org
  Deborah> http://lists.linuxia64.org/lists/listinfo/linux-ia64

