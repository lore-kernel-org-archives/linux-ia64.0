From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 27 Jul 2016 23:00:01 +0000
Subject: Re: [RFC v3 13/13] kprobes: port blacklist kprobes to linker table
Message-Id: <20160727230001.GQ5537@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-14-git-send-email-mcgrof@kernel.org>
 <20160726002722.5011993d23c2bfeff7a14dee@kernel.org>
In-Reply-To: <20160726002722.5011993d23c2bfeff7a14dee@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com

On Tue, Jul 26, 2016 at 12:27:22AM +0900, Masami Hiramatsu wrote:
> On Fri, 22 Jul 2016 14:24:47 -0700
> "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> 
> > kprobe makes use of two sections, the one dealing with the actual
> > kprobes was recently ported using the standard section range API.
> > The blacklist functionality of kprobes is still using a custom
> > section and declaring its custom section using the linker script
> > as follows:
> > 
> > type  Linux-section custom section name  begin                    end
> > table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist
> > 
> > This ports the _kprobe_blacklist custom section to the standard
> > Linux linker table API allowing us remove all the custom blacklist
> > kprobe section declarations from the linker script.
> > 
> > This has been tested by trying to register a kprobe on a blacklisted
> > symbol (these are declared with NOKPROBE_SYMBOL()), and confirms that
> > this fails to work as expected. This was tested with:
> 
> This is OK for me, and if you would like to make sure, please use ftrace to probe
>  (easier  than making new module) and compare debugfs/blacklist which shows
> all blacklisted functions, so if all the function names are same it
> must be OK :).

Ah I see, sure thanks for the tip! I was actually hoping to write a unit
test that automates this testing, but that can be done and submitted later,
the approach you suggest should make writing a unit easier as well.

> Acked-by: Masami Hiramatsu <mhiramat@kernel.org>

Great, thanks,

  Luis
