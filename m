From: "Eric Gillespie, Jr." <epg@progeny.com>
Date: Wed, 25 Jul 2001 23:29:26 +0000
Subject: [Linux-ia64] libgmp3 problem on IA64
Message-Id: <marc-linux-ia64-105590693005920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For the past couple days i have been investigating an odd segfault in
Sawfish.  For some reason, some people were not seeing it, but once it
starts, it is perfectly reproducable, even after eliminating any state
Sawfish saves (Unix domain socket, configuration files, etc.).

The crash only occurs when using session management; it doesn't matter
if you use xsm or gnome-session.  I know the problem is in GMP (the
GNU MultiPrecision library), but i think i'm in over my head at this
point.  Can anyone help?

I've tracked the crash down to the rep_print_number_to_string function
in librep-0.14/src (rep is the extension language used by Sawfish),
show below.  More debugging later on showed me that the crash happens
in libgmp3-3.1.1/mpn/get_str.c, at the very end of mpn_get_str(),
right where you'll find this crap:

while (s != str)
  *--s = 0;

Anyway, here's the tail end of one of my gdb sessions.

(gdb) break numbers.c:2773
Breakpoint 1 at 0x20000000000c3530: file numbers.c, line 2773.
(gdb) cont
Continuing.

Breakpoint 1, Fnumber_to_string (z984315712182462, radix6)
    at numbers.c:2773
2773        out = rep_print_number_to_string (z, rep_INT (radix), -1);
(gdb) step
rep_print_number_to_string (obj984315712182462, radix6, prec=-1)
    at numbers.c:1091
1091        char *out = 0;
(gdb) next
1093        if (!rep_NUMERICP (obj))
(gdb) 
1101            if (radix = 10)
(gdb) 
1103            else if (radix = 16)
(gdb) 
1105            else if (radix = 8)
(gdb) 
1110                obj = promote_to (obj, rep_NUMBER_BIGNUM);
(gdb) 
1111                goto do_bignum;
(gdb) 
1127            out = mpz_get_str (0, radix, rep_NUMBER(obj,z));
(gdb) step

Program received signal SIGSEGV, Segmentation fault.
0x20000000002dad51 in __gmpn_get_str () from /usr/lib/libgmp.so.3
(gdb) 
Single stepping until exit from function __gmpn_get_str, 
which has no line number information.

-- 
Eric Gillespie, Jr. <*> epg@progeny.com
Software Developer
Progeny Linux Systems - http://progeny.com
"I don't know what a Sawfish Window Manager is."

