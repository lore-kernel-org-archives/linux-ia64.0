From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 16 Nov 2000 20:43:54 +0000
Subject: Re: [Linux-ia64] "unsupported reloc" error with ld
Message-Id: <marc-linux-ia64-105590678205736@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205735@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205735@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Can a compiler person out there provide some insight
>on the following error I get with some C++ code when
>doing a final bind with ld:

>fs/fs.o(.IA_64.unwind+0x98b8): unsupported reloc
>(... a bunch of these ...)

The fs.o object file contains a relocation that GNU ld does not support
in the context where it appeared.  It is not possible to say anything more
about this problem without further info.  If you debug the linker, you
can find out the number of the relocation and the context where it is being
used.  Or if you provide object files to me, I can do this.

Are you using gcc?  If you are using some other compiler, then the other
compiler could be emitting relocs that GNU ld doesn't support yet.

The dwarf error messages can be ignored.  The linker is trying to pretty
print error messages by using the debug info to determine the function name
and line number where the problem occured.  This pretty printing code is
failing because the debug info hasn't been relocated yet, and hence isn't
valid as is.  Someday this will be fixed by extending this code to relocate
the debug info before trying to use it if possible.

Neither old message seems relevant to me.

Jim

