From: Mark Maule <maule@sgi.com>
Date: Wed, 21 Dec 2005 18:42:30 +0000
Subject: [PATCH 0/4] msi abstractions and support for altix
Message-Id: <20051221184337.5003.85653.32527@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Mark Maule <maule@sgi.com>

Patch set to abstract portions of the MSI core so that it can be used on
architectures which don't use standard interrupt controllers.

1/4 msi-arch-init.patch
	Add an msi_arch_init() hook which can be used to perform platform
	specific setup prior to msi use.

2/4 msi-callouts.patch
	Define a set of callouts to implement the platform-specific tasks:

	msi_setup - set up plumbing to get a vector directed at a default
	    cpu, and return the corresponding MSI bus address and data.
	msi_teardown - inverse of msi_setup
	msi_target - retarget a vector to a given cpu

	Define the routine msi_register_callouts() which can be called from
	a platform's msi_arch_init() code to override the generic callouts.

3/4 ia64-per-platform-device-vector.patch
	For the ia64 arch, allow per-platform definitions of
	IA64_FIRST_DEVICE_VECTOR and IA64_LAST_DEVICE_VECTOR.
	
4/4 msi-altix.patch 
	Altix specific callouts to implement MSI.
