From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Tue, 22 Apr 2008 10:41:28 +0000
Subject: RE: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <10EA09EFD8728347A513008B6B0DA77A031466E7@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 
> Rather than making these binary patches, why not make them fast
> syscalls and using a vdso page. Some of the priviledged instructions
> are simply reads and we could have that information in a read-only
> data page, so there is no need to do a context switch at all. Others
> could benefit from a fast system call that doesn't do a full context
> switch. 

The issue is we don't want to change Linux code a lot, otherwise it
won't be accepted. If we use same logic with original Linux,
but it is using indirect function call now, binary patching could help
in performance.

> 
> It would be nice if we could come up with a generic implementation for
> such a vdso style interface that could be shared between
> xen/kvm/lguest. 
> 
Introducing a new mechanism to use it to replace Linux code to use them
is another different story.

Eddie
