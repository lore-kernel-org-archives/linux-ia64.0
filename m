From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Feb 2006 20:34:03 +0000
Subject: Re: perfmon2 code review: 32-bit ABI on 64-bit OS
Message-Id: <20060213203403.GK11285@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3C87FFF91369A242B9C9147F8BD0908A02C6955C@cacexc04.americas.cpqcorp.net> <1138221212.15295.35.camel@serpentine.pathscale.com> <20060125222844.GB10451@frankl.hpl.hp.com> <1138649612.4077.50.camel@localhost.localdomain> <1138651545.4487.13.camel@camp4.serpentine.com> <1139155731.4279.0.camel@localhost.localdomain> <1139245253.27739.8.camel@camp4.serpentine.com> <20060210153608.GC28311@frankl.hpl.hp.com> <1139596023.9646.111.camel@serpentine.pathscale.com>
In-Reply-To: <1139596023.9646.111.camel@serpentine.pathscale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bryan O'Sullivan <bos@serpentine.com>
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, perfctr-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Bryan,

On Fri, Feb 10, 2006 at 10:27:02AM -0800, Bryan O'Sullivan wrote:
> 
> On some 64-bit arches (e.g. x86_64), most userspace code is 64-bit,
> while on others (e.g. powerpc), most is 32-bit.  Reducing the number of
> things that a userspace tool or library writer can trip over seems like
> a good thing here, even if it slightly complicates perfmon's internals.
> 
> > Note that there are similar issues with the remapped sampling buffer.
> > There, you need to explicitly compile your tool with a special option
> > to force certain types to be 64-bit (size_t, void *).
> 
> It's pretty normal to just use 64-bit quantities in these cases, and
> cast appropriately.
> 

So if I understand you correctly, you are saying it is best to have bitmasks
hardcoded to u64 and have the kernel cast to match the bitmap_*() interface.
This would not cause any alignment problems on neither 32-bit nor 64-bit system.


-- 

-Stephane
