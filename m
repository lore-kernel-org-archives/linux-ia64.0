From: Jay Lan <jlan@sgi.com>
Date: Fri, 10 Nov 2006 23:56:42 +0000
Subject: [PATCH 0/2] IA64 kdump: MCA handling
Message-Id: <455511BA.3020508@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patchset is to handle MCA notify_die events on IA64.

When MCA occurs, errors are set in the PROM. If these
errors are not reset, the PROM would restart the system at
some point and thus OS is not able to kexec the kdump kernel.
To take care of this situation, a new machine vector is needed
to inform PROM that we are about to start a kdump kernel. The SN
code for this machine vector will issue a SAL call.

This patchset includes two parts.

1/2 The first one is to add a machine vector notifying
    the platform-specific code that a kexec is about to
    occur and the related SN code.
2/2 The second part is to add MCA notify_die events handling.


There is a concern that if there is a hardware failure which cause
the MCA, the second kernel may encounter the same MCA. That is
possible. However, from past experience on IA64 using LKCD, dumps are
successful after most MCAs. There is no guarantee, of course.

[Jack Steiner wrote:]
IA64, at least on the SN platforms, reports MCAs for many problems that
are actually software bugs. Examples include failures like references to
non-existant memory, protected memory, etc.  A crash dump should work ok
after these types of MCAs because the crashdump kernel will usually not
reference the same bad addresses.  This (at least on SN) is the most
common cause of a MCA with the exception of MCAs caused by double bit
memory errors. Dumps after double bit memory errors are usually
successful because the bad page is usually not part of the dump.

- Jay Lan

Patches against 2.6.18, apply on top of kexec-kdump-ia64-2.6.18.patch
and Fix-OS_INIT-handle-IA64 patch from Zou Nan hai.




