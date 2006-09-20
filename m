From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 20 Sep 2006 20:29:35 +0000
Subject: Re: [PATCH] export cpu_sibling_map
Message-Id: <20060920202935.GA5508@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060920195347.GD27323@frankl.hpl.hp.com>
In-Reply-To: <20060920195347.GD27323@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 20, 2006 at 09:23:25PM +0100, Christoph Hellwig wrote:
> On Wed, Sep 20, 2006 at 12:53:47PM -0700, Stephane Eranian wrote:
> > Hello Tony,
> > 
> > For Montecito PMU support, I need to determine, in a kernel module, whether
> > or not threads are enabled. The only reliable way of doing this is to
> > compute the bit-weight of cpu_sibling_map[]. This symbol is exported on
> > x86 systems, but not on IA-64 so far. This patch exports the symbol.
> 
> Exporting global variables is a very bad thing, and we only do it if we
> can't avoid it at all.  In this case it could be easily avoided by
> exporting a nr_siblings_per_cpu() helper.

I also have my doubts about this in terms of hotplug cpu ... what
do you do if not all of the cpus have their siblings on-line?  The
question "Are threads enabled?" doesn't seem to have a simple yes/no
answer.  At best you might ask "Does cpu N have any online siblings?"
but the answer to that question could change before you could make
use of the information.

-Tony
