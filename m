From: Jes Sorensen <jes@sunsite.dk>
Date: Fri, 28 Sep 2001 12:39:28 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805271@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Steffen" = Steffen Persvold <sp@scali.no> writes:

Steffen> David Mosberger wrote:
>>  I haven't looked at it yet, but am planning to do so as part of
>> the 2.4.10 patch.

Steffen> I just discovered that several files in arch/ia64/kernel
Steffen> (more specifically acpi.c, efi.c and iosapic.c) calls ioremap
Steffen> with 0 as size argument. This is ok with the current ioremap
Steffen> implementation which always uses region 6 and therefore in
Steffen> theory doesn't need a size since it's mapped all the
Steffen> time.

This is really borked, it should be changed whether we change the
ioremap() implementation or not. ioremap() really should be treated
identically on all architectures from the users perspective.

Cheers
Jes

