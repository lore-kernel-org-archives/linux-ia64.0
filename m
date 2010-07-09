From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 09 Jul 2010 22:46:53 +0000
Subject: Re: [RFC PATCH --take 2] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT
Message-Id: <AANLkTimi1MgKJqD9rsuQSQqM6f32jj2I5fmvQswl_Nq2@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
In-Reply-To: <AANLkTin0QevX0zZaFc4-LVcoIWfRGmzDKUOSIRKdjKgn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Sat, Jul 3, 2010 at 8:31 PM, Luming Yu <luming.yu@gmail.com> wrote:
> Sorry for the inconvenience. Need to git diff HEAD instead of just git di=
ff
> An update patch has been enclosed in =A0attachment of the reply.

That's better. All the pieces seem to be there.

Which CONFIG options did you turn on for your testing.  My first build
without changing any options failed in irq_ia64.c ... it needs:

+#ifdef CONFIG_TRACE_IRQFLAGS
        if(!current->hardirq_context)
                trace_hardirqs_on_delayed();
+#endif

to avoid a complaint about hardirq_context.

Next I turned on some lockdep options under the "Kernel Hacking"
menu. But probably not the same set that you used for you test.
My kernel crashed during boot with:

PID hash table entries: 4096 (order: -1, 32768 bytes)
Placing 64MB software IO TLB between e000000007580000 - e00000000b580000
software IO TLB at phys 0x7580000 - 0xb580000
------------[ cut here ]------------
WARNING: at kernel/lockdep.c:2310 trace_hardirqs_on_caller+0x220/0x380()
Modules linked in:
kernel unaligned access to 0xffffffffffffffff, ip=3D0xa0000001001aaf41
swapper[0]: error during unaligned kernel access
 -1 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 0000121008022018 ifs : 800000000000048e ip  :
[<a0000001001aaf41>]    Not tainted
(2.6.35-rc3-generic-smp-1-ge892a33)
ip is at kmem_cache_alloc+0xc1/0x220
