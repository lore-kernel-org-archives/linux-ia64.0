From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 May 2004 23:33:45 +0000
Subject: Re: [PATCH] boot parameters mem and max_addr
Message-Id: <16537.31193.84962.322323@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40991DE7.7010401@hp.com>
In-Reply-To: <40991DE7.7010401@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 05 May 2004 13:01:27 -0400, Robert Picco <Robert.Picco@hp.com> said:

  Robert> The boot parameter "mem=" will behave like it does for other
  Robert> LINUX architectures.  The boot parameter "max_addr" can be
  Robert> used to limit the maximum physical address like the old
  Robert> "mem=" feature.

Great!

I applied the ia64-portion of the patch.  There was a merge conflict,
but I fixed that by hand.

Thanks,

	--david
