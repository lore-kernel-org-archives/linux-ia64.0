From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Mar 2003 17:47:09 +0000
Subject: Re: [Linux-ia64] compiling 2.5.60 on hp simulator
Message-Id: <marc-linux-ia64-105590709805985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805984@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805984@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 06 Mar 2003 13:41:20 +0000, Petur Thors <peturth@hi.is> said:

  Petur> Hello list.  I'm having trouble compiling kernel 2.5.60 on
  Petur> the hp-simulator. I'm using the latest(ski version 0943l)
  Petur> IA-64 Linux Developers Kit from the CD. After make menuconfig
  Petur> (in the nue enviroment) I do make and the Makefile from
  Petur> arch/ia64 tells me that I have to update my gas (as --version
  Petur> = 2.9-ia64-000717).  So I update it from the URL given by
  Petur> the Makefile and try again. Then i get gas message: error
  Petur> file number less then one. (from
  Petur> arch/ia64/tools/print_offsets) I also tried using the lastest
  Petur> binutils from gnu compiled with target=ia64-hp-linux and got
  Petur> the same error message.  If you have ANY thoughts or ideas
  Petur> about what to do (maybe update the whole toolchain, gcc ,
  Petur> etc) it would be most welcome. If this is a utterly braindead
  Petur> question i apologies for waisting your time.

The "as" binary that you downloaded is an ia64 binary.  You don't want
that because running "as" under the simulator would be too slow.
Someone would have to build a cross-version of "as" for NUE.  It
should be just a matter of (a) downloading the latest binutils
snapshot onto an x86 machine, (b) configure it for target ia64-linux,
(c) build it, (d) copy resulting as-new into NUE (it's best to link
as-new statically, to avoid shared-library dependency issues).  If you
(or someone else) does that, I certainly would be happy to host the
x86-binary of the fixed ia64 assembler on ftp.hpl.hp.com.

	--david

