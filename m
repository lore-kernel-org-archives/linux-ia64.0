From: Tomas Szepe <szepe@pinerecords.com>
Date: Wed, 24 Mar 2004 10:54:19 +0000
Subject: Re: 2.4.25 + 040218.diff OOPS
Message-Id: <20040324105419.GA20174@louise.pinerecords.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040320115002.GF21377@louise.pinerecords.com>
In-Reply-To: <20040320115002.GF21377@louise.pinerecords.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mar-23 2004, Tue, 10:12 -0700
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> Can you look up these IPs by hand, since ksymoops doesn't work?
> (I always use gdb: "info line *0xe00000000447cfe2").

Ok, I'll try to when (if) the OOPS reappears.

> > Mar 20 11:46:07 columbia kernel: bash[15068]: NaT consumption 2216203124768
> > Mar 20 11:46:07 columbia kernel: 
> > Mar 20 11:46:07 columbia kernel: Pid: 15068, CPU 0, comm:                 bash
> > Mar 20 11:46:07 columbia kernel: psr : 0000121008022038 ifs : 800000000000070f ip  : [<e000000004449e71>]    Not tainted
> 
> > Mar 20 11:47:51 columbia kernel:  <1>Unable to handle kernel NULL pointer dereferencemc[15066]: Oops 11012296146944
> > Mar 20 11:47:51 columbia kernel: 
> > Mar 20 11:47:51 columbia kernel: Pid: 15066, CPU 0, comm:                   mc
> > Mar 20 11:47:51 columbia kernel: psr : 0000121008026018 ifs : 800000000000038c ip  : [<e0000000045a7be1>]    Not tainted
> 
> If these are reproducible, it would be useful to figure out how,
> so I could try it here.

No "luck" so far, the machine has been running solid these days
(except I'm getting occassional segfaults in userland, mainly from
make and bash).

Thanks!
-- 
Tomas Szepe <szepe@pinerecords.com>
