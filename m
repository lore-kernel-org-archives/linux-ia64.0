From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 Aug 2000 17:16:06 +0000
Subject: RE: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Aug 2000 09:02:51 -0700 , "Broadfoot, KenX" <kenx.broadfoot@intel.com> said:

  Ken> I use:
  Ken>	DIG-compliant Enable
  Ken>  Itanium A-step Enable
  Ken>  Itanium A1-step Enable
  Ken>  AzusA hacks Enable
  Ken>  IA64 Machine Check Abort
  Ken>  SMP support

I wouldn't recommendn turning on AzusA hacks unless you have an AzusA
machine.

  Ken> I am not using SoftSDV hacks ( strange I know ) I compile SMP
  Ken> even for the single proc box. It just "seems" more stable.

SoftSDV is for the (Intel) simulator only.  Do _not_ turn this on for
real hw.

	--david

