From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Jul 2004 21:49:58 +0000
Subject: Re: [PATCH] IA64 audit support
Message-Id: <16619.7814.759319.469038@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406301556.i5UFuGg8009251@redrum.boston.redhat.com>
In-Reply-To: <200406301556.i5UFuGg8009251@redrum.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Martuccelli <peterm@redhat.com>
Cc: akpm@osdl.org, faith@redhat.com, davidm@hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ray.lanza@hp.com

The patch is mostly fine with me (it looks identical to me as the last
version I saw from Ray; but my memory may be fuzzy).

There are two minor things I'd like to see changed, though:

 - Use IS_IA32_PROCESS() instead of testing psr.is directly (the macro
   gets defined by system.h and using it ensures that the
   IA-32-specific code will go away if the ia32 subsystem is not
   compiled into the kernel).

 - Remove trailing white-space.

Thanks,

	--david
