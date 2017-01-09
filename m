From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon, 09 Jan 2017 18:29:15 +0000
Subject: Re: [PATCH v6 00/14] linux: generalize sections, ranges and linker tables
Message-Id: <1483986555.26691.46.camel@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
         <20170109145833.11502-1-mcgrof@kernel.org>
         <1483979228.26691.40.camel@linux.intel.com>
         <1483981946.26691.44.camel@intel.com>
In-Reply-To: <1483981946.26691.44.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@lin

On Mon, 2017-01-09 at 19:12 +0200, Andy Shevchenko wrote:
> On Mon, 2017-01-09 at 18:27 +0200, Andy Shevchenko wrote:
> > On Mon, 2017-01-09 at 06:58 -0800, Luis R. Rodriguez wrote:
> > > The only architecture that was not tested was avr32 and that is
> > > because
> > > linux-next fails to compile on it. I'd like to greatly thank
> > > Guenter
> > > Roeck for
> > > his help with testing.
> > 
> > We have a real board here. I would try to check if you provide a git
> > url
> > to your stuff.
> > 
> > I can confirm that breakage happened like in last couple of month.
> > v4.10-rc3 can't be compiled either.
> 
> The culprit commit is
> 
> commit 3a0af8fd61f90920f6fa04e4f1e9a6a73c1b4fd2
> Author: Thomas Graf <tgraf@suug.ch>
> Date:   Wed Nov 30 17:10:10 2016 +0100
> 
>     bpf: BPF for lightweight tunnel infrastructure
> 

This makes modules closer to each other, so,
net/socket.c:348: relocation truncated to fit: R_AVR32_11H_PCREL against
`.text'+2930

But still the module is too big for AVR to do some jumps.

Here I stop investigating it. I had been proposed to get rid of avr32
completely, burden to support is just increasing (no Buildroot support,
no Gcc support, what else do we need?) for no value.

diff --git a/net/core/Makefile b/net/core/Makefile
index f6761b6e3b29..91b7d27bf2c6 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -2,13 +2,13 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o request_sock.o skbuff.o datagram.o stream.o scm.o \
+obj-y := filter.o sock.o request_sock.o skbuff.o datagram.o stream.o
scm.o \
         gen_stats.o gen_estimator.o net_namespace.o secure_seq.o
flow_dissector.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y               += dev.o ethtool.o dev_addr_lists.o dst.o
netevent.o \
-                       neighbour.o rtnetlink.o utils.o link_watch.o
filter.o \
+                       neighbour.o rtnetlink.o utils.o link_watch.o \
                        sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
 
 obj-$(CONFIG_XFRM) += flow.o
-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
