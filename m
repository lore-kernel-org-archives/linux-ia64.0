From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 13 Jun 2000 15:46:42 +0000
Subject: [Linux-ia64] new kdb patch with disassembler support
Message-Id: <marc-linux-ia64-105590678205133@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I grew tired of not being able to disassemble code with kdb. This was
really tedious when I was looking at the PAL problems. So I decided
to add support for it. It is included in this patch and is based on
the BFD code.

Summary of changes:

	- upgrade to 2.4-test1 

	- disassembler support via the id command. Symbol lookups is fully
	  supported. Single stepping now shows code as well. (S.Eranian)

	- restructured machine dependent input/output (kdba_io.c). There was
	  way too much code duplication. A side effect is that with 2 consoles
	  (serial+vga) you can now debug from either places. (S.Eranian)

	- vastly enhanced command line editing (S.Eranian):
		 * (CTRL-U/CTRL-C)
	 	 * history buffer via (CTRL-P/CTRL-N) 
		 * Enter will redo the last command (that's for David!)

	- some code cleanups (David + Stephane)

	- updated backtracing support to latest unwind code (D.Mosberger)

The patch is relative to 2.4-test1 + David's 0609 diff.

It is available from the HPLabs web site at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/kdb-2.4-test1.patch


Enjoy,


Known Issue:
	- on serial line the output of certain editing commands like CTRL-U
	  is bogus but the buffer is valid. This is due to some timing problems
	  with the UART which I did not have time to really fix. Anybody with
	  UART understanding can probably fix this in minutes. Patch welcomed !

-Stephane


