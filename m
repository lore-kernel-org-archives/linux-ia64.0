From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 23 Jul 2001 12:43:01 +0000
Subject: Re: [Linux-ia64] __ia64_syscall ?
Message-Id: <marc-linux-ia64-105590693005865@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005861@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005861@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andreas" = Andreas Schwab <schwab@suse.de> writes:

> Jes Sorensen <jes@sunsite.dk> writes: |> That said please be
> aware that I do not think reiserfs has been ported |> to 64
> bit architectures yet.

Andreas> Hmm, it works just fine here.  All necessary patches should
Andreas> be included in 2.4.7 already.

Ok, I know big endian support is pending, or did Alan submit that
already?

Still doesn't address the issues of it over-writing data beyond it's
partitions, crashing under heavy loads etc.

Jes

