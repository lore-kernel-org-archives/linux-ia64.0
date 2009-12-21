From: Alex Chiang <achiang@hp.com>
Date: Mon, 21 Dec 2009 21:17:24 +0000
Subject: Re: [PATCH 00/11] ACPI: early _PDC eval and unify x86/ia64
Message-Id: <20091221211724.GB28569@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio> <20091221081550.GA1648@isilmar.linta.de>
In-Reply-To: <20091221081550.GA1648@isilmar.linta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dominik Brodowski <linux@dominikbrodowski.net>, venkatesh.pallipadi@intel.com, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

* Dominik Brodowski <linux@dominikbrodowski.net>:
> 
> On Sun, Dec 20, 2009 at 12:19:04PM -0700, Alex Chiang wrote:
> > This does introduce a boot time namespace walk for all the CPUs
> > in the system, looking for and evaluating _PDC. Hopefully that
> > will not make life miserable for the giant SGI clusters. If worse
> > comes to worse, maybe we can quirk them and avoid the namespace
> > walk.
> 
> Could this be done async, with completion before EC initialization?

I don't think I understand your suggestion.

On some platforms, we need to finish evaluating _PDC before we
initialize the EC. That's what I discovered with the Envy 15. At
that point in boot, we're single-threaded and going through early
ACPI initialization. Each step has to finish before the next, in
order for later initialization to succeed.

There's nothing else going on except for waiting for _PDC to
finish so that we can initialize the EC.

My fear was that on a huge compute cluster, walking the namespace
for every CPU object to evaluate _PDC might take a long time, and
is also probably unnecessary, since their hardware/firmware
probably doesn't load dynamic tables in _PDC.

In that case, my suggestion was to avoid the walk with a quirk.

But maybe it's not necessary to worry about that until it's
actually proven to be a problem.

Thanks,
/ac

