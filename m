From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 May 2002 20:29:56 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 8 May 2002 14:43:42 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> I dont think the latest discontig patch makes any assumptions
  Jack> about memory layout and where memory holes appear. This info
  Jack> is passed to the kernel in the ACPI tables.  There are also
  Jack> platform specific macros defined in a platform mmzone_xxx file
  Jack> that are used to provide platform abstractions.

The discontig patch would be a lot more acceptable to me if it didn't
drag in all the other NUMA stuff.  As it stands, it's overkill.

Also, the discontig patch has a buch of hardcoded limits (e.g.,
maximum number of nodes, max. "clumps" per node, etc.), so it's really
not all that general by itself.  It's just more tweakable.

  Jack> Can the zx1 platform provide the necessary ACPI tables?? If
  Jack> so, it would be interesting to see what the asm/mmzone_zx1.h
  Jack> file would look like (assuming it could be done).

All the info needed for discontiguous memory is in the EFI memory
table.  The ACPI tables should be needed only for locality info, which
has very little to do with discontinuity (one usually implies the
other, but not vice versa).

  >>  There have been discussions on this topic on the lkml recently
  >> and different solutions have been proposed.  I don't really care
  >> too much which solution is used in the end as long as it is able
  >> to accommodate arbitrary physical layouts and has no dramatic
  >> performance impact.

  Jack> Agree. I'm certainly happy with any approach that satisfies
  Jack> these requirements.

I think it would be interesting to see a discontig patch which leaves
out all the NUMA stuff.  I really believe it would actually help clean
up that patch a lot.

	--david

