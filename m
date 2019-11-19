From: Mark Brown <broonie@kernel.org>
Date: Tue, 19 Nov 2019 12:00:53 +0000
Subject: Re: [PATCH 09/12] ASoC: Intel: Skylake: Explicitly include linux/io.h for virt_to_phys()
Message-Id: <20191119120053.GA3634@sirena.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com>
 <20191119002121.4107-10-sean.j.christopherson@intel.com>
In-Reply-To: <20191119002121.4107-10-sean.j.christopherson@intel.com>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-acpi@vger.kernel.org, alsa-devel@alsa-project.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 18, 2019 at 04:21:18PM -0800, Sean Christopherson wrote:
> Through a labyrinthian sequence of includes, usage of virt_to_phys() is
> dependent on the include of asm/io.h in x86's asm/realmode.h, which is
> included in x86's asm/acpi.h and thus by linux/acpi.h.  Explicitly
> include linux/io.h to break the dependency on realmode.h so that a
> future patch can remove the realmode.h include from acpi.h without
> breaking the build.

Acked-by: Mark Brown <broonie@kernel.org>

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAl3T2XIACgkQJNaLcl1U
h9Ag5gf8CXRFNxgU/ospZfWpWqo31BrJS3TLJbiQogFQrYt6MzUt/rehd+5DN1bH
rRAsHldAHpkPGu0ZDj4QRiH29Oc0G1xQAPyMbMnG3afcORJp9DkaBs8mLBd4Xh4r
S4bPP4Lr+GeOJepjK6LOz948KigmvpZVDzgGiwqaRZfxT36f92BS3dXnTUoe3Khx
q1z6+agCYbpIS9NtBzVBpuJ1b4opTj4/7G8POfaPbYyGxaI0Mr8mwkwMdwvtXz4V
04C5nyfw5qQmjWqpMQuolxXEPW7DvIpobAYnFHL/qrf5DzSd9Yc5bPUx3Y61swla
VoEhYM6CbdD6hpBeVhY8lbGgINd/1g==
=zPtj
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
