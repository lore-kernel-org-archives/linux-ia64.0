From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 04 Feb 2004 19:04:43 +0000
Subject: RE: [PATCH] turn off irqdebug by default on Altix
Message-Id: <B05667366EE6204181EABE9C1B1C0EB58024B5@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is really confusing with two parameters that do the same thing.
What will happen if someone pass noirqdebug and irqdebug at the same
time?

What's wrong with boot time parameter of noirqdebug?

- Ken


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Martin Hicks
Sent: Wednesday, February 04, 2004 7:29 AM
To: linux-ia64@vger.kernel.org; akpm@osdl.org
Cc: steiner@sgi.com; jbarnes@sgi.com
Subject: [PATCH] turn off irqdebug by default on Altix

Hello,

A while ago there was a discussion, started by Jack Steiner, about a hot
cache line in the irqdebug code that makes booting on large machines
very slow.  The original thread can be found here:

http://marc.theaimsgroup.com/?l=linux-kernel&m6858073229831&w=2

The end result was that it was felt that irqdebug sould remain on by
default on small machines, and that large machines should turn it off be
default if it was causing a problem.

Here is a patch that turns it off for sn2.  It applies cleanly against
the linux-2.5 bk tree from this morning.
mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE
