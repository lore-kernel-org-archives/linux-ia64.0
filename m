From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 21 Oct 2003 06:10:51 +0000
Subject: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106671667126577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm just playing around with the kernel gate DSO and noticed when as
2.14.90.0.6 builds gate-data.o there is a warning:

arch/ia64/kernel/gate-data.S:1: Warning: setting incorrect section
attributes for .data.gate

And when I look in gate-data.o I see

  [ 4] .data.gate        PROGBITS         0000000000000000  00000040
       0000000000000d50  0000000000000000 WAX       0     0     1
                  ^^^^^                   ^^^

I see two things wrong; seeing as this is just a "wrapper" around
gate.so for linking into vmlinux the section should about as big as
gate.so, and it's attributes are set in gate-data.S as "ax" not "wax"
(objdump --disassemble seems to show gate-data.o has everything OK,
just the section header is wrong).

I used an older version of as (2.13.90 from
ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz) and gate-data.o
came out like
                                                                                                                                                
  [ 4] .data.gate        PROGBITS         0000000000000000  00000040
       0000000000004720  0000000000000000  AX       0     0     1

which seems much more reasonable to me.

Is this a binutils bug or have I missed something?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au


