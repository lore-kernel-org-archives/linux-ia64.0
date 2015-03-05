From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Thu, 05 Mar 2015 00:25:52 +0000
Subject: Re: [PATCH v3 1/9] ACPI: fix all errors reported by cleanpatch.pl in osl.c
Message-Id: <3363575.FHEZ9Qjrf1@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org> <1528624.HcuCny6IaW@vostro.rjw.lan> <54F79B9C.1030901@redhat.com>
In-Reply-To: <54F79B9C.1030901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <ahs3@redhat.com>
Cc: al.stone@linaro.org, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

On Wednesday, March 04, 2015 04:56:12 PM Al Stone wrote:
> On 03/04/2015 04:04 PM, Rafael J. Wysocki wrote:
> > On Tuesday, February 24, 2015 05:36:17 PM al.stone@linaro.org wrote:
> >> From: Al Stone <al.stone@linaro.org>
> >>
> >> In preparation for later splitting out some of the arch-dependent code from
> >> osl.c, clean up the errors reported by checkpatch.pl.  They fell into these
> >> classes:
> >>
> >>    -- remove the FSF address from the GPL notice
> >>    -- "foo * bar" should be "foo *bar" (and the ** variation of same)
> >>    -- a return is not a function, so parentheses are not required.
> >>
> >> Signed-off-by: Al Stone <al.stone@linaro.org>
> > 
> > checkpatch.pl is irrelevant here.  You're trying to make the coding style be
> > more consistent with the coding style of the rest of the kernel.
> > 
> > The warnings from checkpatch.pl are meaningless for the existing code, so
> > it should not be used to justify changes in that code.
> > 
> > Of course, the same applies to patches [2-4/9].
> > 
> > 
> 
> Okay, I'm puzzled.  In the last version of these patches, I asked if I
> should clean up osl.c as long as I was creating the new osi.c file.  I
> understood the reply to mean it would also be good to correct osl.c [0]
> from checkpatch's point of view.  I took that to mean errors (patch [1/9])
> and warnings (patches [2-4/9]) -- so that's what I did.  What did I
> misunderstand from that reply?
> 
> If these changes are objectionable, then I'll drop these from the next
> version of the patch set; I'm not hung up on insisting on either of the
> kernel's or ACPI's coding style -- I try to adapt as needed.  I only did
> the patches because I thought it was helping out with some long-term
> maintenance type work.

The changes are basically OK, but the justification is bogus to me.
"I'm making the chagne, because checkpatch.pl told me so" is a pretty bad
explanation in my view.  It is much better to say "This file does not
adhere to the general kernel coding style and since I'm going to split it
into pieces and I want those pieces to follow the coding style more closely,
make changes as follows."

So this is more about the changelogs (and subjects) than the code changes
themselves.


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
