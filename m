From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 30 Mar 2002 00:11:23 +0000
Subject: Re: [Linux-ia64] reading ski trace files
Message-Id: <marc-linux-ia64-105590701905346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905274@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905274@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 17:48:16 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> Just wondering what tool one is meant to use to read the
  Matt> traces produced by ski?  A hexdump is vaguely helpful, but the
  Matt> file format suggests that it's intended to be read by some
  Matt> automated tool :)

OK, you can now get the following file:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/trcread-x86-020329.tar.gz

If you extract it, you'll get an x86 binary called "trcread".  This
program will let you print the trace files collected by ski.  The
trace file contains tons of information and the output of "trcread" is
not really easy to interpret (partly due to lack of documentation).
However, if you just want to generate a memory trace, I'd recommend to
use the -d option.  Interspersed with the normal output, this will
output lines of the form:

	mem:FOO

There is one such line for each memory access in the trace.  FOO is a
line describing the memory access in a format compatible with the
Dinero IV cache simulator.  Briefly, this format is as follows:

 mem:i 00000000001014e0 10
	=> read 16 bytes of instruction from address 00000000001014e0
 mem:r 00000000001035b0 8
	=> read 8 bytes of data from address 00000000001035b0
 mem:w 0000000000103688 4
	=> write 4 bytes of data to address 0000000000103688
 mem:m e0000000004dfc20 1
	=> prefetch cache line from address e0000000004dfc20 (the 1 byte
	   "size" is meaningless)

Semaphore instructions (fetchadd etc.) are output like regular stores
(i.e., there is no separate record for the implied atomic read).

As an example, to get a memory trace with ski, you could something
along the lines of:

	$ ski arch/ia64/boot/bootloader vmlinux single
	* trfile /tmp/foo.trace		# set trace file
	* trace 1			# turn on tracing
	* run				# run time program for a while
	* trace 0			# turn tracing off

Then you could get the Dinero records with:

	$ trcread -d -i /tmp/foo.trace | grep '^mem:'

Needless to say, this program is provided as is, with no warranty,
etc, etc.  But if you find a bug or have a question, please do send
mail to lia64-sim@linux.hpl.hp.com.

Thanks,

	--david

