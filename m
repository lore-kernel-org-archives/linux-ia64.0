From: Grant Grundler <iod00d@hp.com>
Date: Wed, 30 Jul 2003 18:51:33 +0000
Subject: Re: EXT2_MAX_BLOCK_LOG_SIZE increase?
Message-Id: <marc-linux-ia64-105959115622094@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105958015806246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105958015806246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 30, 2003 at 02:21:02PM -0400, Theodore Ts'o wrote:
> I'd be interested in benchmark runs comparing 4k, 8k, 16k, 32k, and
> 64k, if you would, please.  

vary kernel page size or ext2 block size or both together?
re-aim-7 benchmark or something different?
(and please don't say "dbench" :^)

32k is not possible in the kernel. Could use 64k.

Two of the re-aim-7 (aka osdl-aim-7) results (4k and 16k) are posted
on lkml and I can resend if I get a private request.

I'm going to be in transit or offline alot of the next 2 weeks.
Not likely I'll be able to generate the additional numbers.
Other volunteers?
I'm happy to share the s3kr3T osdl-aim-7 sauce recipe.

And I'd really just like to prove if VMERGE code in the BIO layer
is useful or not. I've concluded it's not useful for 53c1030.
I think it's more interesting to measure 53c1010.

> Was any patches necessary for the ia64 kernel before the block sizes >
> 8k started working for you?

nope. :^)
Just twiddle the CONFIG_IA64_PAGE_SIZE_* parameters if one wants 64KB.
16KB is the default.

thanks,
grant
