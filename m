From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Wed, 04 Feb 2015 13:40:30 +0000
Subject: Re: [PATCH v2 3/5] ACPI: add arch-specific compilation for _OSI and the blacklist
Message-Id: <2903181.4VVp3X75UK@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1423009304-5007-1-git-send-email-al.stone@linaro.org> <1423009304-5007-4-git-send-email-al.stone@linaro.org> <2298661.ffvhncbLpr@vostro.rjw.lan>
In-Reply-To: <2298661.ffvhncbLpr@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: al.stone@linaro.org
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Wednesday, February 04, 2015 03:00:15 PM Rafael J. Wysocki wrote:
> On Tuesday, February 03, 2015 05:21:42 PM al.stone@linaro.org wrote:
> > From: Al Stone <al.stone@linaro.org>
> > 
> > Now that all of the _OSI functionality has been separated out, we can
> > provide arch-specific functionality for it.  This also allows us to do
> > the same for the acpi_blacklisted() function.
> > 
> > Whether arch-specific functions are used or not now depends on the config
> > options CONFIG_ACPI_ARCH_SPECIFIC_OSI and CONFIG_ARCH_SPECIFIC_BLACKLIST.
> > By default, both are set false which causes the x86/ia64 versions to be
> > used, just as is done today.  Setting one or both of these options true
> > will cause architecture-specific implementations to be built instead; this
> > patch also provides arm64 implementations.
> > 
> > For x86/ia64, there is no functional change.
> > 
> > For arm64, any use of _OSI will issue a warning that it is deprecated.
> > All use of _OSI will return false -- i.e., it will return no useful
> > information to any firmware using it.  The ability to temporarily turn
> > on _OSI, or turn off _OSI, or affect it in other ways from the command
> > line is no longer available for arm64, either.  The blacklist for ACPI
> > on arm64 is empty.  This will, of course, require ACPI to be enabled
> > for arm64.
> > 
> > Signed-off-by: Al Stone <al.stone@linaro.org>
> > ---
> >  drivers/acpi/Kconfig         | 22 ++++++++++++++++++++++
> >  drivers/acpi/Makefile        | 19 ++++++++++++++++++-
> >  drivers/acpi/blacklist-arm.c | 20 ++++++++++++++++++++
> >  drivers/acpi/blacklist.c     |  5 +++++
> >  drivers/acpi/osi-arm.c       | 25 +++++++++++++++++++++++++
> >  5 files changed, 90 insertions(+), 1 deletion(-)
> >  create mode 100644 drivers/acpi/blacklist-arm.c
> >  create mode 100644 drivers/acpi/osi-arm.c
> > 
> > diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> > index 3e3bd35..4190940 100644
> > --- a/drivers/acpi/Kconfig
> > +++ b/drivers/acpi/Kconfig
> > @@ -369,6 +369,28 @@ config ACPI_REDUCED_HARDWARE_ONLY
> >  
> >  	  If you are unsure what to do, do not enable this option.
> >  
> > +config ACPI_ARCH_SPECIFIC_OSI
> 
> I woulnd't make this and the other one user-selectable.  Let architectures
> select them from their top-level Kconfig files.
> 
> That's what we do with the other CONFIG_ARCH_ things.
> 
> So in the architecture-specific Kconfig you'll have
> 
> config ACPI_ARCH_SPECIFIC_OSI
> 	def_bool n
> 	depends on ACPI
> 
> Moreover, I'd call that ARCH_SPECIFIC_ACPI_OSI.

Or even better, you can define them here (drivers/acpi/Kconfig/) as

config ARCH_SPECIFIC_ACPI_OSI
	def_bool n

and then do

	select ARCH_SPECIFIC_ACPI_OSI if ACPI

as you did in [4/5].


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
