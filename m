From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 29 Jan 2003 14:06:29 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805766@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday 25 January 2003 06:02, David Mosberger wrote:
> Oh, most importantly: you'll need a new assembler in order to use this
> patch.  There was a nasty bug up until Dec 18 last year which
> basically made certain place-relative expressions generate bad data.
> Fortunately, HJ Lu has fixed that bug and I put a read-for-use, static
> binary of a fixed assembler at:
>
> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz
>
> As a measure of safety, I added a sanity check which will cause "make"
> to refuse to build a kernel with a buggy assembler.

David,

which gcc are you using? If I replace "as" with yours, I can't even
"make menuconfig" or "make config". Tried with gcc 2.96 (from RedHat
7.2) and a self compiled gcc 3.2. The executable (mconf) fails. If I
compile the kernel with the new "as", it doesn't boot. Am I the only
one having this problem?

Regards,
Erich


