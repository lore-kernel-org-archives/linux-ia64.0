From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 09 Mar 2005 22:21:19 +0000
Subject: Re: cpu_to_node_map on UP systems
Message-Id: <20050309222119.GA9395@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 09, 2005 at 09:37:29PM +1100, Darren Williams wrote:
> Hi dann
> 
> On Tue, 08 Mar 2005, dann frazier wrote:
> 
> > In 2.6.11, cpu_to_node_map has moved from numa.c to smpboot.c.  Since
> > smpboot.c isn't built on non-SMP systems, this causes non-smp builds to
> > fail to link in various places.
> > 
> > I don't know what the right answer is here - resurrect numa.c maybe?
> We do not seem to have a problem on our Autobuild with CONFIG_SMP=n
> http://www.gelato.unsw.edu.au/kerncomp/
> 
> Just tested latest bk ChangeSet@1.2028, 2005-03-08 16:26:54-08:00, gregkh@suse.de
> tiger_defconfig
> CONFIG_SMP=n
> 
> plus removal of some unwanted drivers builds OK

Is that an IA64_GENERIC build?

