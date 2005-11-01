From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 01 Nov 2005 15:41:26 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <ed5aea430511010741o1fcdbe5dg852f38b1b0947091@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/1/05, Robin Holt <holt@sgi.com> wrote:

> I am trying to get time on one of our larger machines today to run the
> RandomAccess benchmark (as well as some help from somebody that has run
> these before).  Is there a certain number of cpus you would like this
> run on or is a 64p box adequate?

Oh, even a single CPU should be fine.  Just use a large working set. 
IIRC, about 16GB should ensure that not even the page tables fit in
the cache (depending on your cache-size, of course).

Thanks,

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
