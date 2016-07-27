From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 27 Jul 2016 22:40:46 +0000
Subject: Re: [RFC v3 12/13] kprobes: port .kprobes.text to section range
Message-Id: <20160727224046.GN5537@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-13-git-send-email-mcgrof@kernel.org>
 <20160726001958.09b64d73e0bdda461ad1451c@kernel.org>
In-Reply-To: <20160726001958.09b64d73e0bdda461ad1451c@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com

On Tue, Jul 26, 2016 at 12:19:58AM +0900, Masami Hiramatsu wrote:
> On Fri, 22 Jul 2016 14:24:46 -0700
> "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> 
> > kprobe makes use of two custom sections, each custom section
> > is folded into one of the standard Linux sections types as follows,
> > it currently relies on the linker script to fold the custom section
> > onto the respective Linux section:
> > 
> > type  Linux-section custom section name  begin                    end
> > table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist
> > range .text         .kprobes.text        __kprobes_text_start     __kprobes_text_end
> > 
> > This ports the .kprobes.text custom section to the standard
> > Linux ranges API allowing us remove all the custom kprobe section
> > declarations from the linker script.
> > 
> > Tested with CONFIG_KPROBES_SANITY_TEST, it passes with:
> > 
> > Kprobe smoke test: started
> > Kprobe smoke test: passed successfully
> > 
> > Then tested CONFIG_SAMPLE_KPROBES on do_fork, and the kprobe bites
> > and kicks as expected.
> > 
> > Also ran ./ftracetest with no issues:
> > 
> > $ sudo ./ftracetest
> > == Ftrace unit tests => > [1] Basic trace file check      [PASS]
> > [2] Basic test for tracers      [PASS]
> > [3] Basic trace clock test      [PASS]
> > [4] Basic event tracing check   [PASS]
> > [5] event tracing - enable/disable with event level files       [PASS]
> > [6] event tracing - restricts events based on pid       [PASS]
> > [7] event tracing - enable/disable with subsystem level files   [PASS]
> > [8] event tracing - enable/disable with top level files [PASS]
> > [9] ftrace - function graph filters with stack tracer   [PASS]
> > [10] ftrace - function graph filters    [PASS]
> > [11] ftrace - function profiler with function tracing   [PASS]
> > [12] Test creation and deletion of trace instances while setting an event[PASS]
> > [13] Test creation and deletion of trace instances      [PASS]
> > [14] Kprobe dynamic event - adding and removing [PASS]
> > [15] Kprobe dynamic event - busy event check    [PASS]
> > [16] Kprobe dynamic event with arguments        [PASS]
> > [17] Kprobe dynamic event with function tracer  [PASS]
> > [18] Kretprobe dynamic event with arguments     [PASS]
> > [19] event trigger - test event enable/disable trigger  [PASS]
> > [20] event trigger - test trigger filter        [PASS]
> > [21] event trigger - test histogram modifiers   [PASS]
> > [22] event trigger - test histogram trigger     [PASS]
> > [23] event trigger - test multiple histogram triggers   [PASS]
> > [24] event trigger - test snapshot-trigger      [PASS]
> > [25] event trigger - test stacktrace-trigger    [PASS]
> > [26] event trigger - test traceon/off trigger   [PASS]
> > 
> >  # of passed:  26
> >  # of failed:  0
> >  # of unresolved:  0
> >  # of untested:  0
> >  # of unsupported:  0
> >  # of xfailed:  0
> >  # of undefined(test bug):  0
> 
> Looks good to me except for the modpost part.

OK thanks!

> > diff --git a/scripts/Makefile b/scripts/Makefile
> > index 1d80897a9644..77a0cc91628c 100644
> > --- a/scripts/Makefile
> > +++ b/scripts/Makefile
> > @@ -10,6 +10,7 @@
> >  # check-lc_ctype: Used in Documentation/DocBook
> >  
> >  HOST_EXTRACFLAGS += -I$(srctree)/tools/include
> > +HOST_EXTRACFLAGS += -U__KERNEL__
> 
> This looks a add-hoc hack. If we just need SECTION_RNG(SECTION_TEXT, kprobes)
> to convert to section name, can we export the definitions outside of _KERNEL_ ?

We can, it was just a matter of deciding if we were OK with open coding the
section, copying over some defines, or sharing somehow (this was one way) the
header files.

Josh seems to prefer to open coding out the names on the tools we can certanly
do that here as well, I think his point that the names should/will likely
never change is sufficient motivation to avoid all this and prefer open coding
this.

Will do that in the next spin unless I hear otherwise.

  Luis
