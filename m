From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Mon, 24 Apr 2000 09:01:57 +0000
Subject: Re: [Linux-ia64] ld-linux.so
Message-Id: <marc-linux-ia64-105590678205027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kevin" = Kevin Buettner <kev@primenet.com> writes:

Kevin> On Apr 23, 11:02am, Jes Sorensen wrote:
>>  I know very little about the C++ ABI so this may be C++ specific.
>> I thought r8 was meant to be a return register and not an input
>> register and that it's valid to clobber it in any function call,
>> whether the function returns a value or void?

Kevin> When the function in question returns an (non-HFA) aggregate
Kevin> that's larger than 32 bytes (256 bits), r8 is an input register
Kevin> containing the address of the region of memory into which to
Kevin> write the return structure.  When this is the case, r8 is not
Kevin> an output register.  I.e, the calling conventions do not
Kevin> mandate restoring the struct address.

ARGH!

Thats nasty, I would much have preferred to see something like r32
used as the input pointer and have it returned in r8 afterwards. This
way it is going to cause overhead on every single lookup ;-(

Well it's still a bug so we better fix it.

Jes


