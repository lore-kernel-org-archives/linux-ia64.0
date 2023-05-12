From: Jesse Dougherty <Jesse@Cypress-Tech.com>
Date: Fri, 12 May 2023 18:50:04 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <8fea5127-c985-8057-2654-9001cb6256c0@Cypress-Tech.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm a little bias because my company is a re-sellers of the HP Itanium 
ia64 hardware (RX & ZX boxes), as well as PA-RISC. For that reason, I 
would hate to see it fade away in any sector. The ia64 platform is still 
widely used with HP-UX Unix and Open VMS users worldwide. This hardware 
is embedded in most every data center and large and medium companies 
that have been around since the 80s/90s, its probably the oldest box 
they have in there but its the one thats in the corner running for 20 
years, long before most people started working there. PA-RICS is also 
massively intertwined into the US military as well as foreign 
military's, they did that in the early 2000's and they are stuck with it..

I could go on but me as a hardware guy, I'm on team ia64 :-)

Thanks
Jesse Dougherty
Cypress Technology Inc



On 5/12/23 11:57, Ard Biesheuvel wrote:
> (cross posted to several ia64 related mailing list)
>
> Hello all,
>
> As the maintainer of the EFI subsystem in Linux, I am one of the
> people that have to deal with the impact that code refactoring for
> current platforms has on legacy use of such code, in this particular
> case, the use of shared EFI code in the Itanium Linux port.
>
> I am sending this message to gauge the remaining interest in ia64
> support across the OS/distro landscape, and whether people feel that
> the effort required to keep it alive is worth it or not.
>
> As a maintainer, I feel uncomfortable asking contributors to build
> test their changes for Itanium, and boot testing is infeasible for
> most, even if some people are volunteering access to infrastructure
> for this purpose. In general, hacking on kernels or bootloaders (which
> is where the EFI pieces live) is tricky using remote access.
>
> The bottom line is that, while I know of at least 2 people (on cc)
> that test stuff on itanium, and package software for it, I don't think
> there are any actual users remaining, and so it is doubtful whether it
> is justified to ask people to spend time and effort on this.
>
> And for GRUB in particular (which is what triggered this message), it
> is unclear to me why any machines still running would not be better
> served by sticking with their current bootloader build, rather than
> upgrading to a new build with a refactored EFI layer where the best
> case scenario is that it boots the kernel in exactly the same way,
> while there is a substantial risk of regressions.
>
> For the Linux kernel itself, the situation is quite similar. There is
> a non-zero effort involved in keeping things working, and if anyone
> still needs to run their programs on Itanium, it is not clear to me
> why that would require a recent version of the OS.
>
> So bottom line: I am proposing we drop support for Itanium across the
> board. Would anyone have any problems with that?
>
> Kind regards,
> Ard.
