From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Dec 2006 21:36:04 +0000
Subject: RE: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample application
Message-Id: <617E1C2C70743745A92448908E030B2AE65CC0@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Is it better to move above definitions to file include/asm-ia64/pal.h?
> > 
> I'm trying to have the kernel driver as simple as possible and
> leave the complexity to application.

I agree with Fenghua here ... currently this driver leaves all
interpretation of what the values mean to the user application.
The interfaces in /sys are a very thin layer to give access to
the PAL_MC_ERROR_INJECT call ... so the kernel doesn't need any
of this information in asm/pal.h  ...  if it were just a couple
of small structures perhaps I'd let it slide, but there are pages
of bit definitions in the SDM, lots more than I'd care to have
cluttering up what is already a very busy header file.

Besides, putting this information here would just encourage
people to include kernel header files in user applications :-)

When someone comes up with a better suggestion for where to keep
the user side than Documentation/ia64/err_inject.txt, we should
definitely split out these structure definitions into an err_inject.h
to make it easy for you all to write fabulous injection tools.

-Tony
