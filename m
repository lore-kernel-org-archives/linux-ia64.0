From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Oct 2010 21:33:29 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <AANLkTikzh6LhAwmNkciU3P+qhopYiZNg7LvHhaHW2z4N@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Oct 21, 2010 at 9:00 AM, Luck, Tony <tony.luck@intel.com> wrote:
>
> Peer with extra suspicion at the octo-merge since this is the first
> time I've used one of these to pull in all my topic branches. =A0I just
> ran:
> =A0$ git merge release drop_do_IRQ fix_early_irq misc-2.6.37 next-fixes o=
ptimize-unwind remove-compat-h stack_trace

Looks fine to me. You don't need to list the branch you're already in,
so the "release" part of that git merge command is superfluous, but
with any reasonably modern git version, git will prune out any
duplicate branches and not list them twice in the list of parents
(once for the branch you were on, and once for you asking to merge
that same branch). So it's actually pretty hard to really screw up an
octopus merge, since git will even refuse anything that doesn't merge
automatically and cleanly.

                         Linus
