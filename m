From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 24 Nov 2003 16:52:53 +0000
Subject: RE: weird speed problem
Message-Id: <marc-linux-ia64-106969378010242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106957761119369@msgid-missing>
In-Reply-To: <marc-linux-ia64-106957761119369@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> First I've compiled it under shipped red hat... it ran 12 sec, I was
> happy because it took the same amount of time for 64bit amd opteron...
> Then I played with how fast ia32 emulation is (took it about 
> 2-3 minutes
> for the same but ia32 bit compiled program). But then at some point
> after I recompiled it back to ia64 it started running almost 
> as slow as ia32

One _potential_ reason why it ran fast one time, and slow on other runs
is the lack of page colouring in Linux.  If the working set of your test
program is some large percentage of the cache size, then you can hit this
on any architecture, not just ia64.

-Tony Luck
