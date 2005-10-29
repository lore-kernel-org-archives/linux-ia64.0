From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Sat, 29 Oct 2005 02:18:16 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <ed5aea430510281918s35e693b6vc571d583535bb9ec@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 10/28/05, Luck, Tony <tony.luck@intel.com> wrote:

> The worst-case loser from this might be a benchmark that runs
> oodles of small processes (partly from the overhead of the extra
> page, and partly because I suspect that fork/exec/exit might see
> the most impact).  So I'd like to see some AIM7 numbers too.

And I would want to see numbers for the "RANDOM" benchmark (from the
HPCC benchmark suite) for huge data sets (multi-gigabyte; something
big enough such that not even the page tables fit in the caches).

  --david

--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
