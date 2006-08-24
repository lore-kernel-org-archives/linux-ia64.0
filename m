From: Horms <horms@verge.net.au>
Date: Thu, 24 Aug 2006 07:39:39 +0000
Subject: ia64 kexec: control_page
Message-Id: <20060824073937.GE5280@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Nanhai,

As I've mentioned several times in the past I am working on porting
kexec to Xen.  And I am once again casting my eye on porting the ia64
portion.  To this end, I would like to discuss the control_page a
little.

Its currently defined to be 8k + 8k + 4k = 20k bytes long, and assembly
in arch/ia64/kernel/relocate_kernel.S is copied into it.  The resulting
contents looks a bit like this, as per the most recent patch you posted
last week.

  0x0000: relocate_kernel (code)
  ...
  0x0360: memory_stack    (data, 8k)
  ...
  0x2360  register_stack  (data, 8k)
  ...
  0x4360  kexec_fake_sal_rendez (code)
  ...
  0x4640 ia64_dump_cpu_regs (code)
  ...
  0x48c0  end

The problem that I am facing is that in Xen this region, though
contiguous in the kernel, is not actually physically contiguous if the
page size is less than 20k.  As 4k pages don't work for ia64 xen (so I
am lead to believe), this is basically the 16k page case, where the last
0x0360 bytes of the register_stack will be on a second page.

The immediate problem that I have is that I need to pass down the
address of kexec_fake_sal_rendez (and probably ia64_dump_cpu_regs) to
the hypervisor so it can call that code.  This is pretty easy to work
around by just working out which page taking things from there -
fortunately they do not cross a page boundary, even for the 4k case.

One thing that I tried that would alleviate this problem is to reduce
both memory_stack and register_stack to 4k each.  This seems to work on
my Tiger4, but I am not sure what the sizing issues around these areas
are.  Could you elaborate?

Thinking a bit more, it seems that a different layout could help things
even more.  For instance, if all the code was moved to the front, it
should easily fit on one page, even for the 4k case.  Well, that is
unless you are planning to write a lot more assembly.  In which case
additional code pages could be added.  The data areas could be a
separate page (or pages), passed in as arguments to relocate_kernel.

This would probably make the Xen port cleaner (I say probably, because I
haven't finished the port and thus there may be issues I haven't thought
of) without greatly impacting on the linux code.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

