From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Oct 2004 08:08:03 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <16742.19171.341667.367766@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 07 Oct 2004 16:44:09 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> On 10/7/2004 6:27 AM, Christoph Hellwig wrote:
  >> This was rejected for qemu on various arches already.  Please do
  >> it in your userland emulator.

  Arun> I agree that there is no functionality issue here, but there
  Arun> is a performance issue. Doing it in the userland emulator is
  Arun> much slower. What's wrong with the patch ?

  Arun> 	-Arun

  Arun> PS: For others following this thread, the qemu stuff is at:
  Arun> http://groups.google.com/groups?hl=en&lr=&threadm 030407063012%243336%40gated-at.bofh.it

Unfortunately, that thread ran out in a rather unhelpful manner, as
far as I can see.  Rusty seemed to agree that the performance-hit of
doing it all in user-level was unacceptably high, but I didn't see any
actual numbers.  There was a suggestion to decouple the altroot from
the personality which makes some sense, but nobody actually did
anything about it?

	--david
