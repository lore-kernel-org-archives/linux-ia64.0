From: Tim Riker <TimR@CalderaSystems.com>
Date: Wed, 09 Feb 2000 07:28:16 +0000
Subject: [Linux-ia64] Other Linux-ia64 tools?
Message-Id: <marc-linux-ia64-105590678204923@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With the CD you built I probably won't mess with building another ISO
any time soon. I will try reading CD-R and CD-RW discs and tell you if
that works ok. I'd also be happy to be involved in testing any future
CDs as we move down the road.

Are any of the other tools you announced available? From the LWE
presentation:

Toolchain 
  functional IA-64 backend for gcc (egcs)
  IA-64 assembler
  ELF64/IA-64 support in binutils
  kernel- and user-level IA-64 simulator
User-level
  initial GNU libc and libm port
    Native User Environment (/nue)
      turns Linux/x86 machine into Linux/ia64 machine
      allows quick and easy development and building
      of user-level software

I'd like to get going on porting/testing as many apps as I can as soon
as I can. ;-)

PS: nice Virtual Team Picture... ;-)

David Mosberger wrote:
> 
> As far as CD-RW and DVD read capability goes: I have no idea if it
> does.  Not something I can test easily.
> 
> On a related note: I actually had to hack mkisofs to make it possible to
> install an El-Torito image bigger than 2.88MB.  I'm sure I didn't do it
> entirely correctly, so this is something that should be looked into.
> 
> Also, if you use a recent mkisofs, no hacking will be necessary.
> Instead, there is now an option that let's you write "harddisk"-typed
> boot images (sorry, I forgot the option name, but you'll find it by
> searching for El Torito in the cdrecord man page).  This will take
> some fiddling and experimenting to get right, I assume.
> 
>         --david
-- 
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.


