From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 30 Jul 2001 22:06:48 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jose" = Jose Luu <jluu@mainsoft.com> writes:

Jose> Hans wrote:
>> Supporting another ABI is very expensive.  The tradeoffs for HP/UX
>> are different.
>> 

Jose> I am sure I don't realize how expensive it is, but it seems
Jose> worth investigating, for our purposes we need the libc and
Jose> libX11, little else.

Lets just say that libc (glibc) itself is reason enough not to do
it. It's a TON of work and I don't want to see glibc/ia64 being split
for this unless there is a real good reason. I certainly do not want
to maintain two versions.

Jose> Some code is just not worth cleaning up because it is too big,
Jose> and will never require 64 bit addressing, but still useful to
Jose> have in native mode, mostly because of the performance gap
Jose> between ia32 and ILP32 which will moreover widen with the
Jose> McKinley chip. Look at netscape, it has never been cleaned up,
Jose> it was ported on linux alpha using the DEC/Compaq/(Intel now?)
Jose> compiler in taso mode (32 bit pointers).

Linux/Alpha's glibc doesn't support 32 bit pointers afaik.

Jose> DEC/Compaq developped a technology for VMS where one can mix 32
Jose> and 64 bit libraries, I am wondering if the same ideas can be
Jose> applied here (see references below), nowadays this technology
Jose> should be with Intel. This would avoid the fork in the ABI.

The only way what you are asking for requires all library calls to be
made 64 bit. Not to mention that Linux/ia64 doesn't support loading
native ia64 binaries into the lower 4GB segment, we currently load the
text segment at 0x4000000000000000.

Jes

