From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 19:08:03 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 Jan 2003 15:06:29 +0100, Erich Focht <efocht@ess.nec.de> said:

  Erich> which gcc are you using? If I replace "as" with yours, I
  Erich> can't even "make menuconfig" or "make config". Tried with gcc
  Erich> 2.96 (from RedHat 7.2) and a self compiled gcc 3.2. The
  Erich> executable (mconf) fails. If I compile the kernel with the
  Erich> new "as", it doesn't boot. Am I the only one having this
  Erich> problem?

I tried with gcc3.1.  I tried not to break 2.96 but apparently it did
break.  Perhaps it's just time to says that 2.96 is too old and too
buggy to build the v2.5 kernel.  Given that (a) 2.96 is known to
miscompile the MCA code and (b) the distros are moving to gcc3.x
anyhow, I think this isn't unreasonable.

And for those who hate to build the toolchain themselves, there is
gcc-3.1.tar.gz at ftp.hpl.hp.com.  Just extract it, replace the
assembler, then do:

	make CROSS_COMPILE=/opt/gcc3.1/bin

and you should be in business.

	--david

