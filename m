From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 04 Jun 2001 22:29:59 +0000
Subject: [Linux-ia64] IA-64 PMU-based performance monitoring tool available
Message-Id: <marc-linux-ia64-105590693005686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

I have released the first version of a performance monitoring
tool called pfmon which can be used to exercise the IA-64 PMU
kernel support which I have been working on.

This program is meant as a sample tool to show how to use the API.
I strongly support the development of lots of other tools to exploit
the PMU.

Both pfmon and the API are likely to evolve some more over the next
few months. So please don't rely on them too much.

Pfmon allows you to monitor an unmodified IA-64 binary very much like you
can trace system calls with strace.

Currently supported features are:
   - Event counting:
	- all possible events (about 180)
	- thresholding on event counts
	- opcode matching (untested)
	- per process (only) user mode and/or kernel mode monitoring 

   - Hardware sampling:
	- Event Address Resgiters (EARS): data & instructions
	- Branch Trace Buffer (BTB)

So far the tool works only for one process, e.g., if you do a
pfmon on gcc for instance, you will only collect results from the
gcc process not the children.

Limited testing has been done so far (lack of time) on the EARS and BTB.
Also to fully use those 2 features you need to understand what they are
meant for,i.e., sampling and not tracing.

The documentation is mostly inexistent at this point. I wrote a README
that explains how to get started with the tool. Clearly some knowledge
of the PMU is necessary to fully exploit the existing code. 

Requirements:
	- Linux/ia64 kernel >= 2.4.1

	  You can get the latest IA-64 specific patches at:

		http://www.kernel.org/pub/linux/kernel/ports/ia64/

Where to get the tool:
	ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-0.06.tar.gz

Support:
	Please report any bugs to me. Contributions are welcomed.


Enjoy,

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

