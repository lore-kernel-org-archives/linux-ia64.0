From: Magnus =?utf-8?B?R3Jvw58=?= <magnus.gross@rwth-aachen.de>
Date: Mon, 28 Feb 2022 10:46:13 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <Yhyn9cjDV8XfXLHm@fractal.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <202202260344.63C15C3356@keescook>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
In-Reply-To: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: keescook@chromium.org
Cc: akpm@linux-foundation.org, anthony.yznaga@oracle.com, glaubitz@physik.fu-berlin.de, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matoro_bugzilla_kernel@matoro.tk, matoro_mailinglist_kernel@matoro.tk, regressions@leemhuis.info, regressions@lists.linux.dev, viro@zeniv.linux.org.uk

> When the kernel tries to map these with a combined allocation, it asks
> for a giant mmap of the file, but the file is, of course, not at all
> that large, and the mapping is rejected.

> So... I'm trying to think about how best to deal with this. If I or
> anyone else can't think of an elegant solution, I'll send a revert for
> the offending patch next week.

Shouldn't we just be able to patch total_mapping_size() again to instead
sum up all p_memsz fields, instead of comparing minimum and maximum
p_vaddr?

Runtime complexity would be the same as we are iterating through all
segments already anyway. And I would also argue that is the behaviour
that one wanted to see in that function anyway.

If you agree with this, I can post a patch, but I would need to know
what tree to base it on to avoid merge conflicts with the just merged
patch from Alexey.

--
Magnus
