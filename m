From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Dec 2005 17:14:58 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <200512131014.58643.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 13 December 2005 8:42 am, Prarit Bhargava wrote:
> I spent the past day or so looking at a couple of solutions to this problem and 
> the only solution that appears viable is to (as stated previously) create new 
> initcalls of the form
> 
> platform_calltype_initcall(fn,platform)
> 
> ex)
> 	platform_device_initcall(sn_prarit_driver, "sn2");
> 
> which would check the platform type prior to loading a kernel.

I think this is too complicated.  Initcall ordering is fragile as it
is.  I don't think there are enough users of this sort of functionality
to justify complicating it even more with a platform identifier.

> Suggestions/comments?  Anyone think this is too much bother for the original 
> issue of avoiding
> 
> 	if (!ia64_platform_is("sn2"))
> 		return -ENOSYS;

But I still think it is important to keep these ia64_platform_is()
checks out of generic init functions.  There's just too much chance
of inadvertently breaking non-SN platforms.

Can you use the existing machine vector infrastructure to solve this
problem?  For example, what if you added a "platform_device_setup()"
hook that is a no-op on most platforms, but maps to sn_device_setup()
in the SN2 machine vector?  platform_device_setup() would itself be
called as a device_initcall().
