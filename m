From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 23:59:02 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <20040504235902.GE3395@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 05:27:41PM -0500, Mario Smarduch wrote:
> I would think allot of people would like to mmap() /dev/kmem
> to take a quick look at kernel values, atleast that's what I've
> seen on other Unix variants.

yes - and that's a religious issue. I know people would
like like to see /dev/kmem completely removed.

Many wise kernel engineers have advised me to add /proc
or similar "architected" interfaces. That way a program
will merely get an error instead of crashing the box
when the kernel changes it's data structures or how said
structures get used.

grant
