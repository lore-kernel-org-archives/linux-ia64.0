From: dann frazier <dannf@debian.org>
Date: Sat, 01 Apr 2006 00:49:38 +0000
Subject: Re: Fw: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
Message-Id: <20060401004937.GB22813@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060330112531.1959b11e.akpm@osdl.org>
In-Reply-To: <20060330112531.1959b11e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 03/30/06 15:22, Luck, Tony wrote:
> >> Subject: [Bugme-new] [Bug 6307] New: Bug hwclock in kernel 2.6.16
> >...
> >> Most recent kernel where this bug did not occur: Kernel 2.6.8-2-itanium-smp 
> >> (Defauld in Debian 3.1)
> >
> >I can't reproduce this with kernel.org 2.6.15 on an HP rx2600.
> 
> My HP rx2620, HP zx2000 and Intel Tiger are all running 2.6.16-gitlatest and
> none of them hang on hwclock or ntpdate either.
> 
> The config file listed in the bugzilla has a zillion differences from
> arch/ia64/defconfig ... and chance of trying with a kernel based on
> this config?

We've put 3 2.6.16 builds in Debian/sid so far (2.6.16-[234]).
This user didn't specify which one, but I was unable to reproduce on
my HP rx2600 with either -3 or -4, and I see nothing in the -3
changelog that looks like it could've caused this behavior:
  http://changelog.debian.net/linux-2.6

-- 
dann frazier | HP Open Source and Linux Organization
