From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 29 Apr 2016 18:06:19 +0000
Subject: Re: [PATCH 10/12] kexec: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <20160429180619.GT19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviFP-0000je-5t@rmk-PC.arm.linux.org.uk>
 <CAHB_Gur-6oyEheN-Pom7OwivdvrQpCBaXvM1V2H0JPFRCFZthA@mail.gmail.com>
In-Reply-To: <CAHB_Gur-6oyEheN-Pom7OwivdvrQpCBaXvM1V2H0JPFRCFZthA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pratyush Anand <panand@redhat.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Apr 29, 2016 at 08:36:43PM +0530, Pratyush Anand wrote:
> On Thu, Apr 28, 2016 at 2:58 PM, Russell King
> <rmk+kernel@arm.linux.org.uk> wrote:
> > diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
> > index 152da4a48867..9f1920d2d0c6 100644
> > --- a/kernel/ksysfs.c
> > +++ b/kernel/ksysfs.c
> > @@ -128,8 +128,8 @@ KERNEL_ATTR_RW(kexec_crash_size);
> >  static ssize_t vmcoreinfo_show(struct kobject *kobj,
> >                                struct kobj_attribute *attr, char *buf)
> >  {
> > -       return sprintf(buf, "%lx %x\n",
> > -                      paddr_vmcoreinfo_note(),
> > +       phys_addr_t vmcore_base = paddr_vmcoreinfo_note();
> > +       return sprintf(buf, "%pa %x\n", &vmcore_base,
> 
> Why do we pass &vmcore_base? Shouldn't it be vmcore_base?

You seem to not know what the "%pa" format string means.

%p always takes a _pointer_ as per C standard, so the printf argument
must be a pointer.  However, the kernel format strings are extended
with additional suffixes - in this case 'a', which means that we want
to print the contents of a _pointer_ to a phys_addr_t.

Full details in Documentation/printk-formats.txt in the kernel.

The code above is correct.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
