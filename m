From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 01 Feb 2002 21:28:54 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805980@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 30 Jan 2002 20:36:48 +1100, duraid@fl.net.au said:

  >> The kernel DOES NOT generate a printk() for every unaligned
  >> accesses you get, it's throttled.

  Duraid> That's what my intuition told me. But the sysadmin assured
  Duraid> me that the opposite was true. Bad sysadmin.

If you want to catch all unaligned faults, you can do:

	prctl --unaligned=signal gdb PROGNAME

This way, gdb will stop (with a SIGBUS signal) when an unaligned
access occurs.

	--david

