From: Jim Wilson <wilson@redhat.com>
Date: Tue, 26 Nov 2002 17:47:53 +0000
Subject: Re: [Linux-ia64] linker
Message-Id: <marc-linux-ia64-105590709805485@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805484@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805484@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This isn't a topic that can be easily explained in a few mail messages.

There is a book authored by John R Levine _Linkers and Loaders_.  I haven't
read it myself, but I hear it is very good.
http://www.amazon.com/exec/obidos/tg/detail/-/1558604960/ref=lib_rd_btb/102-4344578-4148946?v=glance&s=books

You can find useful info in the various IA-64 ABI documents.  The psABI and
the Software Conventions and Runtime Architecture documents in particular.
These are available via download from the Intel web page for Itanium.
        http://developer.intel.com/design/itanium/arch_spec.htm
See also the ELF standard (gABI), which is available from SCO/Caldera.
        http://www.caldera.com/developers/gabi

You can also learn a bit by using objdump and readelf to pretty print the
contents of an ELF file.  You can also learn a lot by spending time looking
at and/or tracing through the GNU ld sources, though this may take some time.

Jim

