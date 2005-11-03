From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Thu, 03 Nov 2005 21:46:52 +0000
Subject: RE: virtualization hooks patch for ia64 2.6.15
Message-Id: <516F50407E01324991DD6D07B0531AD57E7C51@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com] 
> Sent: Thursday, November 03, 2005 2:36 PM
> To: Magenheimer, Dan (HP Labs Fort Collins); linux ia64 kernel
> Subject: RE: virtualization hooks patch for ia64 2.6.15
> 
> > Comments appreciated.  Tony, if this explanation and
> > more generalized patch doesn't resolve your previously
> > stated philosophical concerns (e.g. don't want to lead
> > x86 Xen changes; and don't know if all virtualization
> > solutions will be instruction-based), please let me know.
> 
> I still don't see a pressing need to rush this into the
> base ... maintaining this out of tree doesn't look like
> it will consume any significant bandwidth for you.

OK.  Would you approve if it comes through the other path
(with all the x86 Xen changes)?  With your blessing,
I might be able to get Xen/ia64 support in the mainstream
at the same time as Xen/x86.
 
> On the patch itself ... can you describe why some of the
> static symbols in entry.S need to be global (load_switch_stack,
> __ia64_leave_syscall, notify_resume_user).

These assembly routines use privilege-sensitive instructions
so calls to these routines need to be replaced with calls to
equivalent routines that are slightly rewritten to avoid those
instructions.  (In an earlier version of the Xen patch, I had
put these rewritten versions in arch/ia64/xen/xenentry.S.)

Thanks,
Dan
