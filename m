From: Matthew Dobson <colpatch@us.ibm.com>
Date: Tue, 09 Nov 2004 19:23:44 +0000
Subject: Re: Externalize SLIT table
Message-Id: <1100028224.3980.7.camel@arrakis>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com>
	 <20041104.105908.18574694.t-kochi@bq.jp.nec.com>
	 <20041104040713.GC21211@wotan.suse.de>
In-Reply-To: <20041104040713.GC21211@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, steiner@sgi.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 2004-11-03 at 20:07, Andi Kleen wrote:
> On Thu, Nov 04, 2004 at 10:59:08AM +0900, Takayoshi Kochi wrote:
> > (3) all distances in one line like /proc/<PID>/stat
> > 
> > % cat /sys/devices/system/node/node0/distance
> > 10 66 46 66
> 
> I would prefer that. 
> 
> -Andi

That would be my vote as well.  One line, space delimited.  Easy to
parse...  Plus you could easily reproduce the entire SLIT matrix by:

cd /sys/devices/system/node/
for i in `ls node*`; do cat $i/distance; done


-Matt

