From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 19 May 2003 19:07:03 +0000
Subject: RE: [Linux-ia64] RE: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705950@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't want the kernel layout to be constrained by something as
> esoteric as kcore.  Let's fix kcore for good.

I like the vmlist solution because it is extensible (e.g. when
I add another address range to the kernel map to split text and
data so that I can replicate the text across nodes, I'll just
add a new entry to vmlist, and the kcore.c code won't be changed
at all).  But as you point out, this also puts some limits on
kernel layout as objects on the vmlist have to be bounded by
VMALLOC_START and VMALLOC_END.

To remove this constraint, we either:
1) need a parallel list to keep tabs on interesting objects
   that are not in vmlist.

2) need to remove the restriction that objects on vmlist are
   in the [VMALLOC_START, VMALLOC_END) address range.

Answer #1 seems like overkill since we only have one object for
the list now, with a tentative plan for a second when kernel text
replication gets implemented.  It also ends up duplicating all the
code in kcore.c that walks vmlist.

Answer #2 would end up with more extensive changes to fs/proc/kcore.c
and also changes to another generic file (mm.vmalloc.c) to make sure
that the out-of-range items on vmlist didn't confuse vmalloc().

I think that #2 looks less messy ... unless someone comes up
with answer #3

-Tony


