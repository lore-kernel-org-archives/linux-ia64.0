From: Jim Wilson <wilson@redhat.com>
Date: Mon, 03 Feb 2003 20:55:18 +0000
Subject: Re: [Linux-ia64] Question about .opd section
Message-Id: <marc-linux-ia64-105590709805802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805798@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805798@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

binutils@sources.redhat.com is a better place to ask questions like this.
This is where the binutils experts hang out.

I found a comment in the IA-64 bfd support that says .opd contains "official
procedure descriptors".  I don't know where the terminology came from though.

The function descriptors are required for executing IA-64 code, so this is
definitely a normal section when using the GNU tools.  The section is
required if present.  The section is created by the linker, if one of the
object files being linked uses a relocation type that requires that a
function descriptor be created, e.g. LTOFF_FPTR22.  The 2-word function
descriptor goes in the .opd section, the address of the descriptor goes in
the GOT, and the gcc generated code loads the address from the GOT.

I don't have easy access to any other IA-64 compiler, so I can't comment on
how other compilers handle this.

Jim

