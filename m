From: Jes Sorensen <jes@sgi.com>
Date: Thu, 29 Jun 2006 12:52:27 +0000
Subject: Re: [PATCH] kprobe invalidate icache of jump buffer
Message-Id: <yq0zmfwgm44.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44A39D6E.1050302@intel.com>
In-Reply-To: <44A39D6E.1050302@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Mao" = bibo, mao <bibo.mao@intel.com> writes:

Mao> Hi, Kprobe inserts breakpoint instruction in probepoint and then
Mao> jump to jmp buffer, the jump buffer icache must be consistent
Mao> with dcache. Here is the patch invalidates jump buffer icache
Mao> area. Without this patch, in some machines there will be fault
Mao> when jumping to jmp buffer where icache content is inconsistent
Mao> with dcache.

Mao> This patch has been tested in my IA32, x86_64 and IA64 box, but
Mao> is not tested in SPARC64 and powerpc architecture. It is based on
Mao> kernel 2.6.17 version.  Signed-off-by: bibo,mao
Mao> <bibo.mao@intel.com> Thanks bibo,mao diff -Nruap

Your patch seems to have been mangled by your mail client. Please also
make it comply with Documentation/CodingStyle

Cheers,
Jes
