From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 02 Nov 2005 18:59:04 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <ed5aea430511021059s3d486d68yb2a8a360756449c6@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin,

Thanks for running all those benchmarks.

On 11/2/05, Robin Holt <holt@sgi.com> wrote:

> Does anybody have any objections to making 4 level the default?

My concern is that 4-level PT really isn't needed on ia64 for all but
the largest machines and adding a 4-th level cannot possibly help
performance and definitely has a (small) cost.  I see that you have a
CONFIG option now, which is good.  I don't have a strong opinion what
should be the default.  Longer term, it would be good to settle on one
implementation, so perhaps it's not a bad idea to make 4-level the
default and see if anyone complains about performance regressions.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
