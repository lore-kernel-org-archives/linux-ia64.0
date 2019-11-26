From: Ingo Molnar <mingo@kernel.org>
Date: Tue, 26 Nov 2019 11:16:18 +0000
Subject: Re: [PATCH 11/12] ACPI/sleep: Convert acpi_wakeup_address into a function
Message-Id: <20191126111618.GA28423@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com>
 <20191119002121.4107-12-sean.j.christopherson@intel.com>
 <7338293.UcAxln0NAJ@kreacher>
 <20191125104803.v6goacte2vjakx64@ucw.cz>
 <20191125170034.GB12178@linux.intel.com>
In-Reply-To: <20191125170034.GB12178@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Len Brown <len.brown@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-acpi@vger.kernel.org, alsa-devel@alsa-project.org


* Sean Christopherson <sean.j.christopherson@intel.com> wrote:

> On Mon, Nov 25, 2019 at 11:48:03AM +0100, Pavel Machek wrote:
> > > On Tuesday, November 19, 2019 1:21:20 AM CET Sean Christopherson wrote:
> > > > Convert acpi_wakeup_address from a raw variable into a function so that
> > > > x86 can wrap its dereference of the real mode boot header in a function
> > > > instead of broadcasting it to the world via a #define.  This sets the
> > > > stage for a future patch to move the definition of acpi_wakeup_address()
> > > > out of asm/acpi.h and thus break acpi.h's dependency on asm/realmode.h.
> > > > 
> > > > No functional change intended.
> > > > 
> > > > Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
> > > 
> > > Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > > 
> > > > --- a/drivers/acpi/sleep.c
> > > > +++ b/drivers/acpi/sleep.c
> > > > @@ -63,9 +63,9 @@ static int acpi_sleep_prepare(u32 acpi_state)
> > > >  #ifdef CONFIG_ACPI_SLEEP
> > > >  	/* do we have a wakeup address for S2 and S3? */
> > > >  	if (acpi_state = ACPI_STATE_S3) {
> > > > -		if (!acpi_wakeup_address)
> > > > +		if (!acpi_wakeup_address())
> > > >  			return -EFAULT;
> > > > -		acpi_set_waking_vector(acpi_wakeup_address);
> > > > +		acpi_set_waking_vector(acpi_wakeup_address());
> > > >  
> > 
> > You might want to store result in a variable... especially since you are
> > turning inline function into real one in a next patch.
> > 
> > And maybe function should be called get_acip_wakeup_address or
> > something? This way it is easy to mistake actual wakeup address from
> > function that gets it...
> 
> Agreed on both counts.
> 
> 
> Ingo,
> 
> Would you prefer a v2 of the entire series (with Acks and removal of Fixes),
> or a v2 that includes only the last two patches?

Yep, that would be handy. I have them committed to tip:core/headers, but 
haven't sent it to Linus yet, and can redo that all with these 
improvements.

Thanks,

	Ingo
