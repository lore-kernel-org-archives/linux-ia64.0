From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 19 Nov 2019 12:09:07 +0000
Subject: Re: [PATCH 00/12] treewide: break dependencies on x86's RM header
Message-Id: <CAKv+Gu9C132peF9_j2rRwRh4s+aWZBY82rgjqmwaE_X=_6y4Zw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com> <20191119111012.GA109842@gmail.com>
In-Reply-To: <20191119111012.GA109842@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Sean Christopherson <sean.j.christopherson@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pm <linux-pm@vger.kernel.org>, linux-efi <linux-efi@vger.kernel.org>, platform-driver-x86@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, alsa-devel@alsa-project.org

On Tue, 19 Nov 2019 at 12:10, Ingo Molnar <mingo@kernel.org> wrote:
>
>
> * Sean Christopherson <sean.j.christopherson@intel.com> wrote:
>
> > x86's asm/realmode.h, which defines low level structures, variables and
> > helpers used to bring up APs during SMP boot, ends up getting included in
> > practically every nook and cranny of the kernel because the address used
> > by ACPI for resuming from S3 also happens to be stored in the real mode
> > header, and ACPI bleeds the dependency into its widely included headers.
> >
> > As a result, modifying realmode.h for even the most trivial change to the
> > boot code triggers a full kernel rebuild, which is frustrating to say the
> > least as it some of the most difficult code to get exactly right *and* is
> > also some of the most functionally isolated code in the kernel.
> >
> > To break the kernel's widespread dependency on realmode.h, add a wrapper
> > in the aforementioned ACPI S3 code to access the real mode header instead
> > of derefencing the header directly in asm/acpi.h and thereby exposing it
> > to the world via linux/acpi.h.
> >
> > Build tested on x86 with allyesconfig and allmodconfig, so hopefully there
> > aren't more build issues lurking, but at this point it wouldn't surprise
> > me in the least if this somehow manages to break the build.
> >
> > Based on tip/master, commit ceceaf1f12ba ("Merge branch 'WIP.x86/cleanups'").
> >
> > Patch Synopsis:
> >   - Patches 01-09 fix a variety of build errors that arise when patch 12
> >     drops realmode.h from asm/acpi.h.  Most of the errors are quite absurb
> >     as they have no relation whatsoever to x86's RM boot code, but occur
> >     because realmode.h happens to include asm/io.h.
>
> Yeah, these kind of parasitic header dependencies are the main driving
> force behind kernel header spaghetti hell: it's super easy to add a new
> header, but very hard to remove them...
>
> Hence they practically only accumulate.
>
> As a result header removal patches get priority, from me at least. :-)
>
> >   - Patch 10 removes a spurious include of realmode.h from an ACPI header.
> >
> >   - Patches 11 and 12 implement the wrapper and move it out of acpi.h.
>
> So if the ACPI maintainers are fine with -tip carrying patches #11 and #12
> then I'd be glad to route these patches upstream.
>
> I've applied them to tip:WIP.core/headers as a work-in-progress tree, and
> I'm testing them on randconfigs to make sure there's no broken
> dependencies. I'll wait for the ACPI acks.
>
> I edited the title of patch 12 slightly, to:
>
>    c8bceb321209: x86/ACPI/sleep: Move acpi_wakeup_address() definition into sleep.c, remove <asm/realmode.h> from <asm/acpi.h>
>
> to make sure the big header dependency change is obvious at first sight.
>

I'm fine with the patches but can we drop the fixes headers please?
This doesn't actually fix anything, and touching early boot stuff for
no good reason should be avoided imo.
