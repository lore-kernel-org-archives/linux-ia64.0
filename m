From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 26 Apr 2001 07:01:12 +0000
Subject: RE: [Linux-ia64] Re: New gnu-efi package and new boot loader avai
Message-Id: <marc-linux-ia64-105590693005471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005448@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005448@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Apr 2001 12:00:32 -0500, "McCaffity, Ray" <ray.mccaffity@wcg.com> said:

  Ray> This doesn't seem to be hurting anything as far as I can tell,
  Ray> but is there a way to fix this?

  Ray> Warning: EFI system table major version mismatch: got 1.02,
  Ray> expected 0.92 EFI v1.02 by INTEL: SALsystab=0x7ff266e0
  Ray> ACPI=0x7fe99cc8 ACPI 2.0=0x7fe99f00 MPS =0x7ffd0000
  Ray> SMBIOS=0xf00a0

This should be fixed in the latest kernel (2.4.3 + ia64).

	--david

