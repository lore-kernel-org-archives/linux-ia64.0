From: Tomas Szepe <szepe@pinerecords.com>
Date: Wed, 24 Mar 2004 13:00:54 +0000
Subject: Re: 2.4.25 + 040218.diff OOPS
Message-Id: <20040324130054.GB20174@louise.pinerecords.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040320115002.GF21377@louise.pinerecords.com>
In-Reply-To: <20040320115002.GF21377@louise.pinerecords.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mar-20 2004, Sat, 12:50 +0100
Tomas Szepe <szepe@pinerecords.com> wrote:

> Mar 20 11:47:51 columbia kernel:  <1>Unable to handle kernel NULL pointer dereferencemc[15066]: Oops 11012296146944
> Mar 20 11:47:51 columbia kernel: 
> Mar 20 11:47:51 columbia kernel: Pid: 15066, CPU 0, comm:                   mc
> Mar 20 11:47:51 columbia kernel: psr : 0000121008026018 ifs : 800000000000038c ip  : [<e0000000045a7be1>]    Not tainted
> Mar 20 11:47:51 columbia kernel: ip is at (no symbol)
[snip]

Ok, this was most likely a false alarm.  HP has just contacted us to
say sorry for having sent us a busted server (they said something about
broken capacitors affecting the bus).  A replacement beast should appear
in about 10 days, I'll be back to report how things are going.

Thanks for understanding!
-- 
Tomas Szepe <szepe@pinerecords.com>
