From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Jan 2014 21:14:16 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DBA315@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony, is GDB working correctly with your gcc 4.8.2-compiled kernel?
> Indeed, one noticeable evidence of optimization's breakage is GDB
> stopping with SIGTRAP at address 0 as soon as GDB's run command is
> executed [1].

Seems ok.  Tested using "GNU gdb (GDB) SUSE (7.5.1-0.7.29) I took a
"Hello World" program. Set a breakpoint at "main". Started running.
It stopped at the breakpoint. "s" stepped a line and printed the
Hello World. "c" continued until child terminated.

Kernel is the latest linux next (tag = next-20140124).

-Tony

