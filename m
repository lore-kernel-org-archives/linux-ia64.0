From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 25 Jan 2001 14:25:09 +0000
Subject: Re: [Linux-ia64] That getpagesize() problem again!
Message-Id: <marc-linux-ia64-105590693005098@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andreas" = Andreas Schwab <schwab@suse.de> writes:

|> What should I do?

Andreas> You need to run kernel 2.4.0-test9 with the 001030 patch or
Andreas> later.  Earlier versions didn't pass AT_PAGESZ in all cases.

Actually the problem is that Francis' rpm binaries have been compiled
and linked statically against an old version of glibc that didn't get
the pagesize from AT_PAGESZ.

Francis you need to get a proper set of RPM binaries for your machines
linked against the new library.

Jes

