From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 20 Jul 2002 07:08:22 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch is at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:

        linux-2.4.18-ia64-020719.diff.gz

This patch has mostly bug-fixes for Itanium 2 machines and a few
additional drivers.  The problem reported by Alex, where the
McKinley-tuned memcpy() causes VGA console corruption has been worked
around by not using memcpy() at all for accessing the framebuffer
(this was arguably the wrong thing to do in the first place).
However, I do not fully understand yet what triggered this problem.
It would be good to make sure it's really not a bug in the new memcpy().
Ken, if you have a chance to look into it, I'd be interested to know
what you find.

I tried this kernel on the Intel Tiger platform, the hp Ski simulator,
and hp zx1 platform and it seems to work quite well.

Enjoy,

        --david

ChangeLog

- Make "xconfig" work again (Keith Owens, Khalid Aziz)
- Add HCDP ACPI serial line support (Khalid Aziz)
- Drop extraneous set_rte() call from iosapic.c (Alex Williamson)
- Fix perfmon SMP initialization ordering bug (Stephane Eranian)
- Include perfmon_mckinley.h now that it's public info (Stephane Eranian)
- Implement pcibios_enable_device for PCI hotplug (Takayoshi Kochi)
- Fix McKinley versions of copy_user()/memcpy() (Ken Chen)
- Fix two small kernel unwinder bugs (based on patch by Richard Henderson)
- Fix mem.c driver to skip over memory-holes (Alex Williamson, I think)
- Include eepro1000 and Tigon3 support (various, plus bug fixes by
  Grant Grundler for these and other gigE cards)
- Update FM801 sound river (Martin Petersen)
- Fix flush_tlb_pgtables() to avoid denial-of-service attacks (Arun
  Sharma)
- Add PCI ID for Quadro4 card
- Fix Radeon and 3dfx fbdev code to work on McKinley
- Make VGA framebuffer code use stupid word-by-word copy routines, not
  regular memcpy() routines
- Fix page allocator to not confuse memory holes with real memory
  (John Marvin & me)


