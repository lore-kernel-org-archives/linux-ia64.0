From: "Bahnsen, Bruce" <bruce.bahnsen@intel.com>
Date: Fri, 17 Jan 2003 17:51:32 +0000
Subject: RE: [Linux-ia64] Error compiling 2.4.20 for i386
Message-Id: <marc-linux-ia64-105590709805714@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks Bjorn

I was under the mistaken impression that the ia64 patch for 2.4.18 and
beyond would not break ia32. I am looking for a way to support both ia32 and
ia64 from a single kernel source. Is there a plan for the ia64 patch to
support this model?

The smp_threads_ready error is just gcc-3 being more picky about matching
volatile qualifiers. I can get ia64 to compile now. However, I'm getting
this link error now...

net/network.o(.debug_info+0x6f4b26): undefined reference to `L5661'

Bruce


-----Original Message-----
From: Bjorn Helgaas [mailto:bjorn_helgaas@hp.com]
Sent: Friday, January 17, 2003 8:06 AM
To: Bahnsen, Bruce; 'linux-ia64@linuxia64.org'
Subject: Re: [Linux-ia64] Error compiling 2.4.20 for i386


On Thursday 16 January 2003 5:42 pm, Bahnsen, Bruce wrote:
> I applied the ia64 patch to the 2.4.20 kernel (all from kernel.org). If I
> try to compile i386 using the default config, I get the following compile
> error:

If you want an i386 kernel, there is no reason to use the ia64 patch.

I'll look at this for the 2.4.21 patch, but in general, I do not pay
any attention to the i386 kernel when producing the ia64 patch.

2.4.20 has very old ACPI bits in it, so the ia64 patch contains a
large ACPI update.  The ia64-specific ACPI bits match, of course,
but I don't bother to update the i386-specific ACPI bits.  So it's
likely that this is a result of that mismatch.

> setup.c: In function `parse_cmdline_early':
> setup.c:792: `enable_acpi_smp_table' undeclared (first use in this
function)
 
> I am getting errors compiling ia64 as well, such as:
> ...
> smpboot.c:92: conflicting types for `smp_threads_ready'

Hmm...  Obviously I don't see this error, but I'm using an old (2.96)
gcc.  Maybe newer ones are pickier.  In any case, I've removed
the "volatile" declaration of smp_threads_ready in smpboot.c, so
this won't be an issue for 2.4.21.

Bjorn

