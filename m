From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Apr 2004 19:25:03 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <16525.25103.572166.675668@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Apr 2004 14:00:40 -0500, Mario Smarduch <cms063@email.mot.com> said:

  Mario> Is there support in IA64 kernel to change a memory mapping
  Mario> from cacheble to uncacheble attribute. By support I mean one
  Mario> function which can accept an addr start/range, make sure
  Mario> in-transit cache data/prefetch hits are synced and upon
  Mario> return gurantee no CPU has any stale data in its caches and
  Mario> after installing the new attribute memory is guranteed
  Mario> synchronized. Or is a combonition of functions/macros
  Mario> required?

Volume 2 (System Architecture) of the ASDM outlines the steps needed
to do such a transition.  All the necessary primitives should be there
in ia64 linux, but there is no single convenient-to-use function to do
this.

In any case, just be careful about not introducing memory attribute
aliases.  You need to be especially careful since the kernel accesses
memory with granule-sized mappings (normally 64MB page size, but on
some machines its 16MB).

	--david
