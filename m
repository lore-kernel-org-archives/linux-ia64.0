From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 06 Nov 2004 13:07:44 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041106130744.GA23897@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com> <20041104040713.GC21211@wotan.suse.de> <20041104.135721.08317994.t-kochi@bq.jp.nec.com> <20041105160808.GA26719@sgi.com> <jevfcknty5.fsf@sykes.suse.de> <20041105164449.GC26719@sgi.com> <20041106115029.GB23305@infradead.org> <20041106124838.GA16434@wotan.suse.de>
In-Reply-To: <20041106124838.GA16434@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jack Steiner <steiner@sgi.com>, Andreas Schwab <schwab@suse.de>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Nov 06, 2004 at 01:48:38PM +0100, Andi Kleen wrote:
> On Sat, Nov 06, 2004 at 11:50:29AM +0000, Christoph Hellwig wrote:
> > On Fri, Nov 05, 2004 at 10:44:49AM -0600, Jack Steiner wrote:
> > > > > +	for (i = 0; i < numnodes; i++)
> > > > > +		len += sprintf(buf + len, "%s%d", i ? " " : "", node_distance(nid, i));
> > > > 
> > > > Can this overflow the space allocated for buf?
> > > 
> > > 
> > > Good point. I think we are ok for now. AFAIK, the largest cpu count
> > > currently supported is 512. That gives a max string of 2k (max of 3 
> > > digits + space per cpu).
> > 
> > I always wondered why sysfs doesn't use the seq_file interface that makes
> > life easier in the rest of them kernel.
> 
> Most fields only output a single number, and seq_file would be 
> extreme overkill for that.

Personally I think even a:

static void
show_foo(struct device *dev, struct seq_file *s)
{
	seq_printf(s, "blafcsvsdfg\n");
}

static ssize_t
show_foo(struct device *dev, char *buf)
{
	return snprintf(buf, 20, "blafcsvsdfg\n");
}

would be a definitive improvement.

