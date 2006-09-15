From: Horms <horms@verge.net.au>
Date: Fri, 15 Sep 2006 09:25:22 +0000
Subject: ia64 kexec: xen -> linux
Message-Id: <20060915092521.GA27714@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

as some of you may be aware I am working on porting kexec
to xen/ia64. I have made a reasoble ammount of progress to this end.
I'll try and get a new patch set on xen-devel some time next week.
However I have a problem that I need some ideas on how to solve.

At the moment when kexecing from xen to linux the boot halts on a call
to efi_gettimeofday(), or more specifically efi.get_time. I'm assuming
that this is more or less the first efi runtime call that is made, and
that it is halting because of a discrepancy in the virtual mapping set
up by efi.set_virtual_address_map().

The problem as I see it is that linux uses a page_offset that covers the
most significant 3 bits, wherase xen uses the first 4. The unfortunate
thing is that efi.set_virtual_address_map() can only be called once,
and I don't think its possible to change the mappings at all once
its been called.

One idea that I had was to make sure that the efi calls are always made
in real mode, and never call efi.set_virtual_address_map() at all - efi
calls have to be made using virtual addressing after
efi.set_virtual_address_map() is called. But can this work?

Another idea from my colleague Magnus was to map the efi runtime calls
into some area of memory that is agreed upon by both Linux and Xen (and
any other kexec-able OS/hypervisor). This seems to be tedious at best.

And a last idea was to replace the efi table with our own calls, much
the same way that xen provideds a virtualised efi table to its domains.
However I'm really not sure if this is possible, as it seems that at
best such functions would be a mechanism to implement the real-mode
approach.

I'd really appreciate some input on whether or not the problem that
I think I am seeing is plausible. And if so, is there a decent way
around it?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

