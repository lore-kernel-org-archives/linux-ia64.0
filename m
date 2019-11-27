From: Ingo Molnar <mingo@kernel.org>
Date: Wed, 27 Nov 2019 17:25:28 +0000
Subject: Re: [PATCH v2 00/12] treewide: break dependencies on x86's RM header
Message-Id: <20191127172528.GB10957@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191126165417.22423-1-sean.j.christopherson@intel.com>
 <20191127072057.GB94748@gmail.com>
 <20191127144703.GA18530@linux.intel.com>
In-Reply-To: <20191127144703.GA18530@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <nadav.amit@gmail.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-acpi@vger.kernel.org, alsa-devel@alsa-project.org


* Sean Christopherson <sean.j.christopherson@intel.com> wrote:

> > You didn't include every patch from v1 though, such us my fix to 
> > Quark:
> > 
> >   [PATCH] x86/platform/intel/quark: Explicitly include linux/io.h for virt_to_phys()
> > 
> > I've applied that one too and your updated patches, and it's now all 
> > pushed out into tip:WIP.core/headers.
> 
> Sorry, it wasn't clear to me whether or not to include that one.  Next 
> time I'll ask.

No problem - in general it's best to include all, because in general it's 
much easier for maintainers to leave out something than to remember to 
add it back in. ;-)

Thanks,

	Ingo
