From: Mark Goodwin <markgw@sgi.com>
Date: Thu, 25 Jan 2001 06:43:15 +0000
Subject: Re: [Linux-ia64] Announce: IA-64 cross compiler on IA-32 available
Message-Id: <marc-linux-ia64-105590693005095@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Jan 2001, Khalid Aziz wrote:

> I recently built the latest version of IA-64 cross compiler on IA-32
> with all of the patches that have been posted on this mailing list. I
> have made the binaries available at
> <ftp://puffin.external.hp.com/pub/ia64/gcc-2.96-ia64-000717-snap001117-build2.tar.gz>.
> The compiler is configured to be installed under /opt/ia64. I have built
> and tested kernels with it. I have also built a few applications which
> worked. Let me know if anything is missing from this package.

Did the applications you built actually run? I compiled hello world
but it wouldn't run on TurboLinux release 000828 English Frontier (Burning
Man) because the cross compiler linked it with /lib/ld-linux-ia64.so.2
(which points to ld-2.2.so), but the os has /lib/ld-linux-ia64.so.1
(points to ld-2.1.3.so, which is in glibc-2.1.3).

Which os issue are you using? Since most machines out there are
still glibc-2.1.3, could you perhaps recompile for that (or make your
src tree and build instructions available and I'll do it?)

thanks

-- Mark Goodwin
SGI Engineering.


