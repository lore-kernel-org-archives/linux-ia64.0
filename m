From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:13:22 +0000
Subject: Re: [PATCH v7 04/14] tables.h: add linker table support
Message-Id: <20170119111322.GJ28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-5-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-5-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:10:47PM -0800, Luis R. Rodriguez wrote:
> A linker table is a data structure that is stitched together from items
> in multiple object files. Linux has historically implicitly used linker
> tables for ages, however they were all built in an adhoc manner which
> requires linker script modifications, per architecture. This adds a
> general linker table solution so that a new linker table can be
> implemented by changing C code only. The Linux linker table was
> inspired by Michael Brown's iPXE's linker table solution, it has been
> been completely re-written and adapted for integration and use on Linux.

Ok, I understand that, but then you say:

> The same philosophy is borrowed, extended and further simplified:

This line made no sense :(

> Linker tables enable an extremely light weight linker build time
> solution for feature ordering and selection, this can help to both
> simplify init sequences in a generic fashion and helps avoiding code
> bit-rotting when desirable. Further changes will be added later
> which will make more evident how code bit rot can be avoided using
> linker tables.

I have no idea why this is needed, nor what it means.  I fail to
understand the bit-rot reference.

thanks,

greg k-h
