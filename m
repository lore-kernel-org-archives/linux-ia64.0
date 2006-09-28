From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 28 Sep 2006 14:04:06 +0000
Subject: Re: 2.6.18 perfmon new code base + libpfm + pfmon
Message-Id: <20060928140406.GF18245@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060926143420.GF14550@frankl.hpl.hp.com> <20060926220951.39bd344f.akpm@osdl.org> <20060927224832.GA17883@frankl.hpl.hp.com> <20060928134126.GA14635@infradead.org>
In-Reply-To: <20060928134126.GA14635@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Chritoph,

On Thu, Sep 28, 2006 at 02:41:26PM +0100, Christoph Hellwig wrote:
> this completly leaves out my comments, which you also seemed to ignore before
> :)

It is true I forgot to list your comments in the summary I sent out yesterday.
However rest assured that I took them into account. If you noticed in my annoucement
for 2.6.18, I have removed the perfmon KAPI interface, for instance. As for the UUID
 to string conversion, this was also pointed out by Andrew and it is work-in-progress.

So here is the additional feedback I will put in the summary:

[hch]: remove perfmon kernel-level API (perfmon_kapi.c), it is not justified
	- done

[hch]: use strings insead of UUID
	- work in progress

In general, I do listen to comments. The summary of changes is a good proof
of that, I think.

Thanks.

-- 
-Stephane
