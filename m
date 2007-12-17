From: "de Dinechin, Christophe (Integrity VM)"
Date: Mon, 17 Dec 2007 10:42:10 +0000
Subject: RE: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating
Message-Id: <7575980D7C4188408E8BDB171DA164B73A875EC53C@G3W1111.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
In-Reply-To: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Do you know what the call sequence looks like for the few cases where
> your patch doesn't manage to avoid (you mentioned just 170 times out
> of several million in the patch submission)?

One of the stack traces happens (at least for RedHat 2.6.9-42.EL) during module loading / unloading. This one seems quite legitimate to me. I don't know if there are others.

 [<a00000010005b3d0>] local_flush_tlb_all+0xd0/0x1e0
 [<a000000100053cd0>] smp_flush_tlb_all+0x70/0xa0
 [<a000000100119e50>] unmap_vm_area+0x390/0x3c0
 [<a00000010011a820>] __remove_vm_area+0x80/0xe0
 [<a00000010011a8b0>] remove_vm_area+0x30/0x80
 [<a00000010011a980>] __vunmap+0x80/0x2a0
 [<a00000010011ac40>] vfree+0xa0/0xc0
 [<a000000100050430>] module_free+0x90/0xc0


Regards
Christophe
