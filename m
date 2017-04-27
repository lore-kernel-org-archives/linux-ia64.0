From: Dave Young <dyoung@redhat.com>
Date: Thu, 27 Apr 2017 03:06:07 +0000
Subject: Re: [PATCH v4 1/3] kexec: Move vmcoreinfo out of the kernel's .bss section
Message-Id: <20170427030607.GB10602@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1492688374-27903-1-git-send-email-xlpang@redhat.com>
 <20170426071916.GD5381@dhcp-128-65.nay.redhat.com>
 <59006DAB.8030908@redhat.com>
 <59007405.6070107@redhat.com>
In-Reply-To: <59007405.6070107@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: xlpang@redhat.com
Cc: Juergen Gross <jgross@suse.com>, linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Baoquan He <bhe@redhat.com>, kexec@lists.infradead.org, Petr Tesarik <ptesarik@suse.cz>, linux-kernel@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, akpm@linux-foundation.org, Michael Holzheu <holzheu@linux.vnet.ibm.com>

[snip]
> >>>  
> >>>  static int __init crash_save_vmcoreinfo_init(void)
> >>>  {
> >>> +	/* One page should be enough for VMCOREINFO_BYTES under all archs */
> >> Can we add a comment in the VMCOREINFO_BYTES header file about the one
> >> page assumption?
> >>
> >> Or just define the VMCOREINFO_BYTES as PAGE_SIZE instead of 4096
> > Yes, I considered this before, but VMCOREINFO_BYTES is also used by VMCOREINFO_NOTE_SIZE
> > definition which is exported to sysfs, also some platform has larger page size(64KB), so
> > I didn't touch this 4096 value.
> >
> > I think I should use kmalloc() to allocate both of them, then move this comment to Patch3 
> > kimage_crash_copy_vmcoreinfo().
> 
> But on the other hand, using a separate page for them seems safer compared with
> using frequently-used slab, what's your opinion?

I feel current page based way is better.

For 64k page the vmcore note size will increase it seems fine. Do you
have concern in mind?

Thanks
