From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Feb 2003 22:12:50 +0000
Subject: [Linux-ia64] beta for ski v0.9.81 available
Message-Id: <marc-linux-ia64-105590709805936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A beta version of ski v0.9.81 is now available for testing.  Ski is a
relatively fast IA-64 instruction set simulator which is useful both
for application-level and system-level software development.
For more info, see this URL:

	http://www.hpl.hp.com/research/linux/ski/

Since this is a beta, there may be some rough edges or unexpected
features (aka "bugs").  If you find such things, please report them on
lia64-sim@linux.hpl.hp.com.

Major enhancements include:

 o Full coverage of SDM2.1.  In particular, the 16-byte atomic
   operations are now supported by Ski.

 o System-level simulation is now a lot faster (about twice as fast)
   thanks to some optimization work by Laurent Morichetti.

 o The "cstack" (call-stack) command now finally works, courtesy of
   libunwind.

For more detailed release notes, see:

  http://www.hpl.hp.com/research/linux/ski/release-notes.php#v0.9.81l1

The Ski web site provides binaries for x86 and ia64 free of charge and
also provides a sample Linux kernel, bootloader, and root file-system.

Enjoy,

	--david

