From: Dave Anderson <anderson@redhat.com>
Date: Thu, 25 Jul 2002 17:38:27 +0000
Subject: [Linux-ia64] insmod bug causes kernel unwind failures for module text
Message-Id: <marc-linux-ia64-105590701905831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a bug in the initialization of the unw_table_entry structures for
all kernel modules, such that any unwind operation that comes upon a kernel
module text address will fail to find its associated unwind info data in
the build_script() routine.  (Actually it won't be able to determine what
module it belongs to.)

The reason that the unwind fails is due to the faulty initialization of
each module's unw_table structure, specifically the start and end fields.
For example, here's a typical module unw_table structure, in which the
"start" field is less than its "segment_base", and the "end" field is not
even in the module's address space:

  crash> unw_table 000000116cd5008
  struct unw_table {
    next = 0xe000000116cd51e8,
    name = 0xa000000000150b30 "keybdev",
    gp = 0xa000000000150ed8,
    segment_base = 0xa0000000001500c0,
    start = 0xa000000000150000,
    end = 0xa00000000014f740,
    array = 0xa000000000150a50,
    length = 0x7
  }

The build_script() routine can never find a module in which the target
IP fits between start and end, so it bails out thinking it's come upon
a leaf routine.

As it turns out, the real problem is due to the contents of the array of
unw_table_entry structures, the first and last of which are used to
calculate the start and end fields:

  static void
  init_unwind_table (struct unw_table *table, const char *name,
        unsigned long segment_base, unsigned long gp,
        const void *table_start, const void *table_end)
  {
          const struct unw_table_entry *start = table_start, *end table_end;

          table->name = name;
          table->segment_base = segment_base;
          table->gp = gp;
==>      table->start = segment_base + start[0].start_offset;
==>      table->end = segment_base + end[-1].end_offset;
          table->array = start;
          table->length = end - start;
  }

The "start[0].start_offset" and "end[-1].end_offset" values contain
invalid negative numbers.  Using the keybdev.o example above, here's what
its 7 unw_table_entry structures look like:

  crash> unw_table_entry 0xa000000000150a50 7
  struct unw_table_entry {
    start_offset = 0xffffffffffffff40,
    end_offset = 0xfffffffffffffcb0,
    info_offset = 0xfffffffffffff680
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffffca0,
    end_offset = 0xfffffffffffffb60,
    info_offset = 0xfffffffffffff660
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffffb60,
    end_offset = 0xfffffffffffffa40,
    info_offset = 0xfffffffffffff640
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffffa40,
    end_offset = 0xfffffffffffff890,
    info_offset = 0xfffffffffffff620
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffff880,
    end_offset = 0xfffffffffffff810,
    info_offset = 0xfffffffffffff600
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffff800,
    end_offset = 0xfffffffffffff6f0,
    info_offset = 0xfffffffffffff5e8
  }
  struct unw_table_entry {
    start_offset = 0xfffffffffffff6e0,
    end_offset = 0xfffffffffffff680,
    info_offset = 0xfffffffffffff5c8
  }

The faulty negative numbers are incorrectly calculated and initialized
by insmod.  David Mosberger pointed me in the proper location, where
there is a bug in obj/obj_ia64.c, in the arch_apply_relocation() routine,
as it applies to .IA_64.unwind relocations:

    case R_IA64_SEGREL32LSB :   /* @segrel(sym + add), data4 LSB */
    case R_IA64_SEGREL64LSB :   /* @segrel(sym + add), data8 LSB */
        if (targsec->header.sh_type & SHT_NOBITS)
            v = ifile->bss - v;
        else if (targsec->header.sh_flags & SHF_EXECINSTR)
            v = ifile->text - v;
        else
            v = ifile->data - v;
        if (r_info = R_IA64_SEGREL32LSB)
            COPY_32LSB(loc, v);
        else
            COPY_64LSB(loc, v);
        break;

In the case of .IA_64.unwind section data, each reallocation operation
mistakenly falls into the default path above where it does the
"v = ifile->data - v;" calculation.

What it should do, in the case of unw_table_entry data, is shown in the
patch below, which assigns offset values that the kernel init_unwind_table()
expects to find:

--- obj/obj_ia64.c.orig Thu Jul 25 12:31:58 2002
+++ obj/obj_ia64.c      Thu Jul 25 12:22:08 2002
@@ -915,6 +915,8 @@
            v = ifile->bss - v;
        else if (targsec->header.sh_flags & SHF_EXECINSTR)
            v = ifile->text - v;
+       else if (targsec->header.sh_type = SHT_IA_64_UNWIND)
+           v = v - ifile->text;
        else
            v = ifile->data - v;
        if (r_info = R_IA64_SEGREL32LSB)

although it doesn't address David M's questioning the SHF_EXECINSTR
calculation as well -- or the others for that matter.  Should those be
flipped as well?

Dave Anderson


