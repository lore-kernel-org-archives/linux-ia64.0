From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 29 Apr 2016 09:30:46 +0000
Subject: Re: [PATCH 2/3] kexec: ensure user memory sizes do not wrap
Message-Id: <20160429093046.GR19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQt-0001U2-Oa@rmk-PC.arm.linux.org.uk>
 <20160428110722.GA28541@dhcp-128-25.nay.redhat.com>
 <20160428122209.GZ19428@n2100.arm.linux.org.uk>
 <20160429093221.GA23421@dhcp-128-25.nay.redhat.com>
In-Reply-To: <20160429093221.GA23421@dhcp-128-25.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Minfei Huang <mhuang@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On Fri, Apr 29, 2016 at 05:32:21PM +0800, Minfei Huang wrote:
> On 04/28/16 at 01:22pm, Russell King - ARM Linux wrote:
> > On Thu, Apr 28, 2016 at 07:07:22PM +0800, Minfei Huang wrote:
> > > On 04/14/16 at 09:00pm, Russell King wrote:
> > > > Ensure that user memory sizes do not wrap around when validating the
> > > > user input, which can lead to the following input validation working
> > > > incorrectly.
> > > > 
> > > > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > > > ---
> > > >  kernel/kexec_core.c | 2 ++
> > > >  1 file changed, 2 insertions(+)
> > > > 
> > > > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > > > index 8d34308ea449..d719a4d0ef55 100644
> > > > --- a/kernel/kexec_core.c
> > > > +++ b/kernel/kexec_core.c
> > > > @@ -169,6 +169,8 @@ int sanity_check_segment_list(struct kimage *image)
> > > >  
> > > >  		mstart = image->segment[i].mem;
> > > >  		mend   = mstart + image->segment[i].memsz;
> > > > +		if (mstart > mend)
> > > > +			return result;
> > > 
> > > The type of image->segment[i].memsz is unsigned. So it is no need to
> > > have a test here.
> > 
> > Absolutely wrong.  Consider the case:
> > 
> > 	segment[i].mem = 0xfff00000;
> > 	segment[i].size = 0x00200000;
> > 
> > Here, mstart will be 0xfff00000, and mend will be 0x00100000.  Just
> > because it's some random type does not make things magically work.
> 
> Hi, Russell.
> 
> Do you mean in PAE mode? If so, we will be in big trouble, because there
> are a lot of functions which use unsigned long to store memory address,
> and this type is 32 bit in PAE mode.

This is basic input validation stuff, it's got nothing to do with whether
we're in PAE mode.  If we get passed such a segment as I illustrate above,
we should detect and fail it, just as we detect and fail other similar
errors.

I'm not sure what the big deal here is.  This is basic validation checks
for stuff coming from userspace which the kernel should be doing as a
matter of course to protect itself.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
