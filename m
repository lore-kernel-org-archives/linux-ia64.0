From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 20 Sep 2006 20:55:25 +0000
Subject: Re: [PATCH] export cpu_sibling_map
Message-Id: <20060920205525.GG27323@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060920195347.GD27323@frankl.hpl.hp.com>
In-Reply-To: <20060920195347.GD27323@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

On Wed, Sep 20, 2006 at 01:29:35PM -0700, Luck, Tony wrote:
> On Wed, Sep 20, 2006 at 09:23:25PM +0100, Christoph Hellwig wrote:
> > On Wed, Sep 20, 2006 at 12:53:47PM -0700, Stephane Eranian wrote:
> > > Hello Tony,
> > > 
> > > For Montecito PMU support, I need to determine, in a kernel module, whether
> > > or not threads are enabled. The only reliable way of doing this is to
> > > compute the bit-weight of cpu_sibling_map[]. This symbol is exported on
> > > x86 systems, but not on IA-64 so far. This patch exports the symbol.
> > 
> > Exporting global variables is a very bad thing, and we only do it if we
> > can't avoid it at all.  In this case it could be easily avoided by
> > exporting a nr_siblings_per_cpu() helper.
> 
> I also have my doubts about this in terms of hotplug cpu ... what
> do you do if not all of the cpus have their siblings on-line?  The
> question "Are threads enabled?" doesn't seem to have a simple yes/no
> answer.  At best you might ask "Does cpu N have any online siblings?"
> but the answer to that question could change before you could make
> use of the information.
> 

I think you bring up an interesting issue. because of HOTPLUG, I need to
register a cpu hotplug  notifier to make sure I get called to take
the appropriate action. As Christoph is suggesting, it is probably
best to hide the variable behind a helper function. Of course, there is
still a race between  the insertion of the module and a hotplug event.
Maybe there is a lock I could grab to serialize this?

This reminds me that I have a similar hotplug issue on P4.

Thanks

-- 
-Stephane
