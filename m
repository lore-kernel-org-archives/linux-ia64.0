From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 15 Oct 2002 12:34:28 +0000
Subject: [Linux-ia64] Re: loading a kernel module
Message-Id: <marc-linux-ia64-105590709805162@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Oct 2002 13:23:12 +0200, 
Christian Hildner <christian.hildner@hob.de> wrote:
>when doing insmod on my kernel module, I get the error message
>"Unhandled relocation of type 72 for label_name"

Interesting, that looks like this relocation type
  #define R_IA64_PCREL60B         0x48    /* @pcrel(sym + add), brl */
which is not handled by any version of modutils.  I need :-

gcc version (gcc -v)
binutils version (ld -v)
the module .o file (compressed, please).

Send all that data to kaos@ocs.com.au (not the list) so I can update
modutils to handle it.


