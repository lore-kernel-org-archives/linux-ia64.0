From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Oct 2005 23:28:07 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0495CC79@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This implies that PIPE_BUF should be equal to the kernel's configured
>page size on ia64.  I modified my test to report on PIPE_BUF's returned
>value, and it is 4096 on all my tested architectures, including ia64 on
>2.6.8 and 2.6.12.

4096 is possibly for historical reasons.

>(Also, the page size on my 2.6.8 ia64 kernel is 16K, same as my 2.6.12
>kernel.)

Yes, the default pagesize on ia64 is 16k.

>It strikes me that, if this is correct, forcing 4K page size isn't the
>right fix.  Do you have any ideas on that front?

My experiment with a 4K page kernel was just that, an experiment. I
didn't intend it to be a fix.  But it is a good thing to try when
some generic test fails on ia64 and works on everything else.

Looking at fs/pipe.c ... it appears that pipe_readv() only
wants to let any writers know that we've read anything if
we manage to empty one of the page buffers:

	if (!buf->len) {

		...


		do_wakeup = 1;
	}

Now, the question becomes "is this a bug". As you pointed
out in an earlier e-mail the standard makes no mention of
what happens when you read some data from a full pipe. So
we appear not to be in violation of the letter of the standard.

But this does fly in the face of common sense.

As you say above, reporting the PIPE_BUF value as PAGE_SIZE
[probably max(4096, PAGE_SIZE) ... for any arch that has a
page size smaller than 4k] would fix this.  But then we get
back to the historical properties of 4k as the PIPE_BUF size.
Would such a change break existing applications that are not
well enough written to use fpathconf(fd, _PC_PIPE_BUF)?

-Tony
