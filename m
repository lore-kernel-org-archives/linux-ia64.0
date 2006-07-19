From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 19 Jul 2006 02:11:33 +0000
Subject: Re: Problem with Guile on ia64 (possibly "getcontext" related)
Message-Id: <6768.1153275093@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87ac7ajylc.fsf@raven.defaultvalue.org>
In-Reply-To: <87ac7ajylc.fsf@raven.defaultvalue.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rob Browning (on Tue, 18 Jul 2006 18:40:07 -0700) wrote:
>Keith Owens <kaos@ocs.com.au> writes:
>
>> Wild guess, based on no data.  Add '__attribute__ ((returns_twice))' to
>> the definition of ia64_getcontext.  That should remove the need to use
>> setjmp.
>
>That also seems to fix the crash.

Good.

>So would it be correct to say that the likely problem is just that
>because Guile calls getcontext via asm, gcc doesn't know that the call
>needs to be handled specially?

Exactly right.

