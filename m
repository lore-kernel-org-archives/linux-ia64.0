From: Pete Wyckoff <pw@osc.edu>
Date: Fri, 03 Nov 2000 13:32:50 +0000
Subject: Re: [Linux-ia64] Re: gdb null ptr
Message-Id: <marc-linux-ia64-105590678205649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205647@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205647@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

wilson@cygnus.com said:
> I don't see how this can happen from looking at the source.  We only cache
> a type in dwarf2_cached_types if it has a DW_AT_name attribute, and if it
> does have such an attribute, then the type should have a name or tag name.
> 
> Can you provide me with a testcase?  A binary that I can run under gdb should
> be sufficient.  You could put it in ftp.cygnus.com/incoming and then mail
> the file name to me.
> 
> Since this doesn't appear to be an ia64 specific problem, if I don't have a
> testcase then I will just punt to the gdb developers
> 	 http://sources.redhat.com/gdb/#bugs

It may very well be a gdb bug.  Anyway, I put a huge executable in
the incoming dir as pw-gdb-bug-ex.

    3078a3f848cba6d1f76fbfe3707b0464  pw-gdb-bug-ex

Here's what happens for the non-patched gdb:

ia1$ /home/pw/cygnus/build/gdb/gdb pw-gdb-bug-ex 
GNU gdb 5.0-ia64-000717
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.  This version of GDB is supported
for customers of Cygnus Solutions.  Type "show warranty" for details.
This GDB was configured as "ia64-unknown-linux"...
(gdb) b output
Segmentation fault

And with the patch:

ia1$ /usr/local/cygnus/bin/gdb pw-gdb-bug-ex
GNU gdb 5.0-ia64-000717
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.  This version of GDB is supported
for customers of Cygnus Solutions.  Type "show warranty" for details.
This GDB was configured as "ia64-unknown-linux"...
(gdb) b output
Breakpoint 1 at 0x400000000002a190: file put.F, line 32.
(gdb) 

Running gdb on itself:

ia1$ /usr/local/cygnus/bin/gdb /home/pw/cygnus/build/gdb/gdb
GNU gdb 5.0-ia64-000717
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.  This version of GDB is supported
for customers of Cygnus Solutions.  Type "show warranty" for details.
This GDB was configured as "ia64-unknown-linux"...
(gdb) run pw-gdb-bug-ex
GNU gdb 5.0-ia64-000717
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.
Type "show copying" to see the conditions.  This version of GDB is supported
for customers of Cygnus Solutions.  Type "show warranty" for details.
This GDB was configured as "ia64-unknown-linux"...
(gdb) b output

Program received signal SIGSEGV, Segmentation fault.
0x20000000001a2661 in strcmp () from /lib/libc.so.0
(gdb) where
#0  0x20000000001a2661 in strcmp () from /lib/libc.so.0
#1  0x40000000001e7c20 in tag_type_to_type (die=0x6000000000120460, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:4526
#2  0x40000000001e7910 in die_type (die=0x6000000000045130, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:4440
#3  0x40000000001e2290 in read_subroutine_type (die=0x1, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:2788
#4  0x40000000001dcda0 in process_die (die=0x6000000000120070, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:1393
#5  0x40000000001dd590 in read_file_scope (die=0x60000000000f7630, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:1556
#6  0x40000000001dcd70 in process_die (die=0x60000000000f7630, 
    objfile=0x60000000000bdf10) at ../../src/gdb/dwarf2read.c:1390
#7  0x40000000001dc8e0 in psymtab_to_symtab_1 (pst=0x600000000011b9f8)
    at ../../src/gdb/dwarf2read.c:1335
#8  0x40000000001dc540 in dwarf2_psymtab_to_symtab (pst=0x600000000011b9f8)
    at ../../src/gdb/dwarf2read.c:1270
#9  0x400000000009c8c0 in psymtab_to_symtab (pst=0x600000000011b9f8)
    at ../../src/gdb/symfile.c:393
#10 0x400000000008e120 in lookup_symbol (name=0x9fffffffffffe420 "output", 
    block=0x0, namespace=VAR_NAMESPACE, is_a_field_of_this=0x0, 
    symtab=0x9fffffffffffe458) at ../../src/gdb/symtab.c:782
#11 0x4000000000095410 in decode_line_1 (argptr=0x9fffffffffffe728, 
    funfirstline=1, default_symtab=0x0, default_line=0, 
    canonical=0x9fffffffffffe720) at ../../src/gdb/symtab.c:3201
#12 0x400000000016d630 in parse_breakpoint_sals (address=0x9fffffffffffe728, 
    sals=0x9fffffffffffe730, addr_string=0x9fffffffffffe720)
    at ../../src/gdb/breakpoint.c:4680
#13 0x400000000016d980 in break_command_1 (arg=0x6000000000079a38 "", flag=0, 
    from_tty=0) at ../../src/gdb/breakpoint.c:4763
#14 0x400000000016f7b0 in break_command (arg=0x6000000000079a32 "output", 
    from_tty=0) at ../../src/gdb/breakpoint.c:5217
#15 0x4000000000144df0 in execute_command (p=0x6000000000079a37 "t", 
    from_tty=1) at ../../src/gdb/top.c:1552
#16 0x40000000000cd7b0 in command_handler (
    command=0x6000000000079a30 "b output") at ../../src/gdb/event-top.c:515
#17 0x40000000000ceac0 in command_line_handler (
    rl=0x60000000000d0b50 "b output") at ../../src/gdb/event-top.c:811
#18 0x4000000000309020 in rl_callback_read_char ()
    at ../../src/readline/callback.c:114
#19 0x40000000000cae60 in rl_callback_read_char_wrapper (
    client_data=0x9fffffffffffea90) at ../../src/gdb/event-top.c:166
#20 0x40000000000cd3c0 in stdin_event_handler (error=0, client_data=0x0)
    at ../../src/gdb/event-top.c:422
#21 0x400000000017e980 in handle_file_event (event_file_descF87702)
    at ../../src/gdb/event-loop.c:742
#22 0x400000000017d8a0 in process_event () at ../../src/gdb/event-loop.c:377
#23 0x400000000017d9b0 in gdb_do_one_event (data=0x6000000000045130)
    at ../../src/gdb/event-loop.c:414
#24 0x40000000001424f0 in catch_errors (
    func=0x40000000003a8e00 <ia64_dis_names+101264>, args=0x0, 
    errstring=0x400000000035def8 "", mask=6) at ../../src/gdb/top.c:616
#25 0x400000000017da50 in start_event_loop () at ../../src/gdb/event-loop.c:438
#26 0x40000000000cb0c0 in cli_command_loop () at ../../src/gdb/event-top.c:196
#27 0x400000000003eb50 in captured_command_loop (data=0x6000000000045130)
    at ../../src/gdb/main.c:104
#28 0x40000000001424f0 in catch_errors (
    func=0x40000000003a8b60 <ia64_dis_names+100592>, args=0x0, 
    errstring=0x4000000000337dd8 "", mask=6) at ../../src/gdb/top.c:616
#29 0x4000000000040720 in captured_main (data=0x9ffffffffffff800)
    at ../../src/gdb/main.c:749
#30 0x40000000001424f0 in catch_errors (
    func=0x40000000003a8990 <ia64_dis_names+100128>, args=0x9ffffffffffff800, 
    errstring=0x4000000000337dd8 "", mask=6) at ../../src/gdb/top.c:616
#31 0x4000000000040790 in main (argc=2, argv=0x9ffffffffffff838)
    at ../../src/gdb/main.c:761
(gdb) 

We can shift this to the gdb developers if you're satisfied it's not
ia64 specific.

		-- Pete

