From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 23 Jul 2001 12:45:10 +0000
Subject: Re: [Linux-ia64] __ia64_syscall ?
Message-Id: <marc-linux-ia64-105590693005866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005861@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005861@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Wilck <Martin.Wilck@fujitsu-siemens.com> writes:

Martin> Hi Jes,
>> That said please be aware that I do not think reiserfs has been
>> ported to 64 bit architectures yet. That and the number of severe
>> problem reports that keeps coming in about it, I'd strongly
>> recommend you stay far away from it and try a better file system.

Martin> ReiserFS works on SuSE/IA64. Andreas Schwab told me so (I
Martin> wouldn't believe it either), I tried it here (not extensively,
Martin> though) and so far I have had no problems. It appears that
Martin> ReiserFS "simply" needs a few additional patches the SuSE
Martin> kernels include.

Hmmm I still wouldn't trust it for any of my data, I have heard of
several incidents where people suddenly start seeing crashes and other
partitions gets corrupted.

>> If you want a journaled file system, I recommend you take a look at
>> XFS or EXT3. I know that Martin Petersen got XFS going on the Alpha
>> so it should work fine on the ia64 as well.

Martin> It seems that SGI is now providing XFS patches against recent
Martin> kernels.  Might be worth a try now ... so far I've refused to
Martin> use their CVS kernel tree.

XFS would certainly be my choice for anything larger than a couple of
gigabytes.

Jes

