From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 28 Aug 2003 19:25:14 +0000
Subject: Re: [Discontig-devel] Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106209895720920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 26, 2003 at 12:13:07PM -0400, Martin Hicks wrote:
> 
> 
> On Tue, Aug 26, 2003 at 05:39:32PM +0200, Xavier Bru wrote:
> > 
> > I tried to put find_memory()  after acpi_numa_init() as in 2.5.72, but 
> > now we get:
> >      bootmem alloc of 100 bytes failed! in acpi_table_init()
> > that now uses the bootmem allocator.
> > 
> > I wonder what should be the right order for initialisation, and if
> > there are ia64 platforms running 2.6.0 with CONFIG_NUMA. Any help is
> > apreciated.
> 
> Jesse Barnes has an unreleased patch to make SGI SN2 work, which does
> move the find_memory() after acpi_numa_init().  There is another patch,
> which I've attached, which removes the bootmem alloc of memory in ACPI.

I talked with Andy Grover about this and I think he agreed to remove the
alloc_bootmem calls from ACPI table initialization, so we should be ok
once that gets merged into Linus' tree.  I'll double check with Andy
when I get back.

Jesse
