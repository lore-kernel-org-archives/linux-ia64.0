From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 23 Jul 2001 12:22:24 +0000
Subject: Re: [Linux-ia64] __ia64_syscall ?
Message-Id: <marc-linux-ia64-105590693005863@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005861@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005861@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jes,

> __ia64_syscall is obsolete. The reiserfs-tools package should use the
> syscall() interface instead. What they doing is also wrong on the ia32
> though it happens to work.

Thanks for the quick response.

> That said please be aware that I do not think reiserfs has been ported
> to 64 bit architectures yet. That and the number of severe problem
> reports that keeps coming in about it, I'd strongly recommend you stay
> far away from it and try a better file system.

ReiserFS works on SuSE/IA64. Andreas Schwab told me so (I wouldn't believe
it either), I tried it here (not extensively, though) and so far I have
had no problems. It appears that ReiserFS "simply" needs a few additional patches
the SuSE kernels include.

I am currently trying to find out what these patches are.

> If you want a journaled
> file system, I recommend you take a look at XFS or EXT3. I know that
> Martin Petersen got XFS going on the Alpha so it should work fine on
> the ia64 as well.

It seems that SGI is now providing XFS patches against recent kernels.
Might be worth a try now ... so far I've refused to use their CVS kernel
tree.

Thanks again,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




