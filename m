From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Mar 2009 15:52:44 +0000
Subject: RE: [GIT PULL] percpu, cpumask, x86 updates for v2.6.30
Message-Id: <57C9024A16AD2D4C97DC78E552063EA39B0A4102@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903281341100.3994@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ingo,

Thanks for looking at this ... I'll try to do some sanity checks
on the IRQ stats to make sure that they make sense.

I do question this part:

> It didnt crash though: this commit has been in linux-next for 2
> months.

I've been building linux-next for ia64 at least a couple of
times a week ... and I didn't see the build error from these
changes there.  First time I saw it was when it showed up in Linus'
tree.  Can you check that all of your trees are in the list
to pull into linux-next?  Perhaps this one got missed?

-Tony

