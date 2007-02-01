From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Thu, 01 Feb 2007 06:02:59 +0000
Subject: Re: [Fastboot] [PATCH] kexec: Avoid migration of already disabled irqs (ia64)
Message-Id: <aec7e5c30701312202if17f943v2b5944675f5e22b1@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C005C1.5010606@sgi.com>
In-Reply-To: <45C005C1.5010606@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/31/07, Zou, Nanhai <nanhai.zou@intel.com> wrote:
> > From: Magnus Damm [mailto:magnus.damm@gmail.com]
> > Booting into a crash kernel does not seem to work on this ia64 box
> > unfortunately. I'm about to investigate why, but I thought trying and
> > fixing kexec was a good first step.
> >
>   That is probably caused by HP's IOMMU engine not shutting down at crash time....,
> Please try add machvec=dig option for the crash dump kernel.
>   However we still need to find a light way to correctly shutdown IOMMU engine on those HP platforms.

It does unfortunately not seem to help. Regardless of SMP or UP kernel.

I'll try to track down where things lock up. Thanks.

/ magnus
