From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Tue, 20 May 2008 04:48:05 +0000
Subject: RE: ld2.acq - sign extension?
Message-Id: <51CFAB8CB6883745AE7B93B3E084EBE201BCBFAD@pdsmsx412.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Avi> Maybe a bug in the instruction emulator?
> 
> Yeah it smells like it, that or in QEMU. I am not quite sure who is
> responsible for this part. Does QEMU just provide registers somewhere
> else and the instruction emulation reads them out of the QEMU share
> space, or is there some other magic going on?

This instruction access IO port of VGA or VGA framebuffer, so it will
trap into KVM,
It is qemu emuate this IO access, while it is kvm to emulate the
behavior of "zero extend" of ld2.acq.
Will fix it soon.


Zxt2 is not necessary after ld2.acq,

Thanks,
Anthony
