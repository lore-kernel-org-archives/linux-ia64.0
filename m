From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 09 Nov 2005 00:08:53 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <ed5aea430511081608o9603b27k8ba92f6ffa6b2637@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/8/05, Gerald Pfeifer <gp@suse.de> wrote:

> OSVs and ISVs, on the other hand, usually prefer to only test and harden
> and qualify/certify a single kernel (which is why Dan's approach to Xen/ia64
> looks quite appealing).

That's a completely bogus argument though.  Perhaps the ISV is stupid
enough not to realize what happens when you boot with pgsizedK but
it certainly doesn't avoid combinatorial explosion (e.g., programs
that have 16KB page size hardcoded still may fail...).

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
