From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 06 Nov 2004 11:50:29 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041106115029.GB23305@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com> <20041104040713.GC21211@wotan.suse.de> <20041104.135721.08317994.t-kochi@bq.jp.nec.com> <20041105160808.GA26719@sgi.com> <jevfcknty5.fsf@sykes.suse.de> <20041105164449.GC26719@sgi.com>
In-Reply-To: <20041105164449.GC26719@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: Andreas Schwab <schwab@suse.de>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, ak@suse.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Nov 05, 2004 at 10:44:49AM -0600, Jack Steiner wrote:
> > > +	for (i = 0; i < numnodes; i++)
> > > +		len += sprintf(buf + len, "%s%d", i ? " " : "", node_distance(nid, i));
> > 
> > Can this overflow the space allocated for buf?
> 
> 
> Good point. I think we are ok for now. AFAIK, the largest cpu count
> currently supported is 512. That gives a max string of 2k (max of 3 
> digits + space per cpu).

I always wondered why sysfs doesn't use the seq_file interface that makes
life easier in the rest of them kernel.

