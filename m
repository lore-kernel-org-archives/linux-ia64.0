From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Nov 2002 00:22:01 +0000
Subject: [Linux-ia64] Re: O(1) scheduler fix for 2.5-ia64
Message-Id: <marc-linux-ia64-105590709805332@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 4 Nov 2002 19:53:07 +0100, Erich Focht <efocht@ess.nec.de> said:

  Erich> Hi David, this problem is wellknown and I actually thought
  Erich> that it was solved. But it looks like the complex
  Erich> prepare_arch_switch() etc. macros didn't make it into the 2.5
  Erich> kernels for IA64. They are needed on IA64 because we have to
  Erich> release the runqueue lock during context switch. This is
  Erich> similar to sparc64. Thanks to John Hawks for noticing this.

Yes, this seems to have fallen through the cracks.  Can you remind me
what the deadlock scenario looked like?

	--david

