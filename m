From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Nov 2005 21:36:18 +0000
Subject: RE: virtualization hooks patch for ia64 2.6.15
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04DC0833@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Comments appreciated.  Tony, if this explanation and
> more generalized patch doesn't resolve your previously
> stated philosophical concerns (e.g. don't want to lead
> x86 Xen changes; and don't know if all virtualization
> solutions will be instruction-based), please let me know.

I still don't see a pressing need to rush this into the
base ... maintaining this out of tree doesn't look like
it will consume any significant bandwidth for you.

On the patch itself ... can you describe why some of the
static symbols in entry.S need to be global (load_switch_stack,
__ia64_leave_syscall, notify_resume_user).

-Tony
