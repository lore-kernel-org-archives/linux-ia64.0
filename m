From: Minfei Huang <mhuang@redhat.com>
Date: Fri, 29 Apr 2016 10:45:39 +0000
Subject: Re: [PATCH 2/3] kexec: ensure user memory sizes do not wrap
Message-Id: <20160429104539.GB23421@dhcp-128-25.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQt-0001U2-Oa@rmk-PC.arm.linux.org.uk>
 <20160428110722.GA28541@dhcp-128-25.nay.redhat.com>
 <20160428122209.GZ19428@n2100.arm.linux.org.uk>
 <20160429093221.GA23421@dhcp-128-25.nay.redhat.com>
 <20160429093046.GR19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160429093046.GR19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On 04/29/16 at 10:30am, Russell King - ARM Linux wrote:
> > > > > @@ -169,6 +169,8 @@ int sanity_check_segment_list(struct kimage *image)
> > > > >  
> > > > >  		mstart = image->segment[i].mem;
> > > > >  		mend   = mstart + image->segment[i].memsz;
> > > > > +		if (mstart > mend)
> > > > > +			return result;
> > > > 
> > > > The type of image->segment[i].memsz is unsigned. So it is no need to
> > > > have a test here.
> > > 
> > > Absolutely wrong.  Consider the case:
> > > 
> > > 	segment[i].mem = 0xfff00000;
> > > 	segment[i].size = 0x00200000;
> > > 
> > > Here, mstart will be 0xfff00000, and mend will be 0x00100000.  Just
> > > because it's some random type does not make things magically work.
> > 
> > Hi, Russell.
> > 
> > Do you mean in PAE mode? If so, we will be in big trouble, because there
> > are a lot of functions which use unsigned long to store memory address,
> > and this type is 32 bit in PAE mode.
> 
> This is basic input validation stuff, it's got nothing to do with whether
> we're in PAE mode.  If we get passed such a segment as I illustrate above,
> we should detect and fail it, just as we detect and fail other similar
> errors.
> 
> I'm not sure what the big deal here is.  This is basic validation checks
> for stuff coming from userspace which the kernel should be doing as a
> matter of course to protect itself.

Hi, Russell.

Thanks for your reply. I'm fine with this basic test now.

Please feel free to add
Reviewed-by: Minfei Huang <mhuang@redhat.com>.

Thanks
Minfei
