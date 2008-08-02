From: "Tony Luck" <tony.luck@intel.com>
Date: Sat, 02 Aug 2008 18:09:54 +0000
Subject: Re: [git pull] ia64 change (include/asm-ia64 -> arch/ia64/include/asm)
Message-Id: <12c511ca0808021109x78227335v4c39f1098a4bfeee@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA3082ABD3A@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3082ABD3A@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Aug 2, 2008 at 10:14 AM, Robin Holt <holt@sgi.com> wrote:
> Just a minor nit that I can't figure out.  Following a build, a
> git-status shows untracked files of:
>
> # Untracked files:
> #   (use "git add <file>..." to include in what will be committed)
> #
> #       arch/ia64/kernel/vmlinux.lds
> #       include/asm-ia64/
>
> I posted a change for the vmlinux.lds (or maybe it was just a question),

I think I remember that ... but I can't find it in the e-mail
archives. vmlinux.lds
needs to be added to .gitignore

> but I am not sure what to do with include/asm-ia64/.  It contains two
> files that are generated:
> asm-offsets.h  nr-irqs.h
>
> I get the feeling we should be generating those into
> arch/ia64/include/asm, but I am not certain.

Sam said in reply to a similar question:

 asm-offsets.h is a generated file and I wanted to avoid adding
 generated files to arch/$ARCH/include.

 It was also a less intrusive patch to keep it at the old location.
 But I recall that it troubles me a bit before I got it
 correct but the kbuild changes all take care of this.

So this is currently correct ... but it sounds like it may change if
someone comes up with a better idea for where generated header
files should go.

-Tony
