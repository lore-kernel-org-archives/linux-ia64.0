From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 24 Apr 2001 12:02:13 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.3)
Message-Id: <marc-linux-ia64-105590693005452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Gustavo" = Gustavo Niemeyer <niemeyer@conectiva.com> writes:

Gustavo> Hi David!!!
>> - Hack fs/binfmt_elf so that the auxiliary information is passed
>> independent of whether the binary is statically or dynamically
>> linked (Rich, I haven't run this past Linus yet, but I hope he
>> won't have an issue with it; it really makes no sense at all to not
>> pass this info for static binaries: an ELF file is an ELF file, no
>> matter whether it's static or dynamic).

Gustavo> This doesn't seem to be working well here. I've checked both
Gustavo> glibc 2.2.1 and the latest 2.2.2 from CVS and I was still
Gustavo> getting the following error:

You need the April kernel and the latest glibc-2.2.3 from CVS and it
should work fine.

We are not going to revert the patch.

Jes

