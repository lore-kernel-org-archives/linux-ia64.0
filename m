From: Steve Tynor <tynor@atlanta.twr.com>
Date: Mon, 02 Oct 2000 17:20:09 +0000
Subject: [Linux-ia64] gcc -O2
Message-Id: <marc-linux-ia64-105590678205531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm using 

    # gcc -v
    Reading specs from /usr/lib/gcc-lib/ia64-cygnus-linux/2.9-ia64-000216-final/specs
    gcc version 2.9-ia64-000216-final

as bundled in Turbolinux 0823

   # uname -a
   Linux impromptu 2.4.0test7-000823-42 #1 Sat Aug 26 16:31:32 PDT 2000 ia64 unknown


I've diagnosed a seg fault that seems to stem from a bad optimization by
gcc -O2.  I can't find any FAQ that discusses known problems with the
ia64 gcc. Is there one?  Is -O2 considered generally usable? or is it
well known that one ought to avoid it in this release?  How 'bout
vanilla -O? (my particular test case works OK with -O but it's hardly an
exhaustive test...).

Where should I direct gcc bug reports -- on this list, or to the general
gcc bug reporting mechanism (a query on GNATS on gcc.gnu.org shows no
matches on the search string "ia64"... Mmmm.... :-)).

Ought I avoid gcc and skip directly to the SGI sgicc? 

Steve

