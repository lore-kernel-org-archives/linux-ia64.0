From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Nov 2006 00:36:58 +0000
Subject: RE: [patch] More Itanium PAL spec updates
Message-Id: <617E1C2C70743745A92448908E030B2ABC8815@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610302243.k9UMhnr723897048@clink.americas.sgi.com>
In-Reply-To: <200610302243.k9UMhnr723897048@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+#define PAL_MEMORY_BUFFER	277	/* Provide cacheable memory for PAL */

This call looks like a new headache for kexec :-(  While there are
hooks to relocate the buffer, I can't see a way to just take back
the buffer ... which makes life hard when kexec'ing from one kernel
to a possibly entirely unrelated OS.  It might be a whole lot better
if the OS didn't touch this (SAL or EFI could set up the buffer?)



+		     "Max Purges                     : %d\n"
 		     "Size of RR.rid                 : %d\n",
 		     vm_info_1.pal_vm_info_1_s.phys_add_size,
 		     vm_info_2.pal_vm_info_2_s.impl_va_msb+1,
 		     vm_info_1.pal_vm_info_1_s.max_pkr+1,
 		     vm_info_1.pal_vm_info_1_s.key_size,
 		     vm_info_1.pal_vm_info_1_s.hash_tag_id,
+		     vm_info_2.pal_vm_info_2_s.max_purges?
+				vm_info_2.pal_vm_info_2_s.max_purges : 1,

max_purges = 65535 means "unlimited".  Should we be helpful here and
print an explicit "unlimited" ... or rely on users having read SDM page
2:451?

-Tony
