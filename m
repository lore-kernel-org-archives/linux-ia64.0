From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Jun 2004 22:56:52 +0000
Subject: RE: [PATCH] new ".serialize" gas directive
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0179489E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I see that the LOAD_PHYSICAL macro expansion includes a tag, which is
>kind of like a label.  Perhaps there was a problem with tags in earlier
>gas versions, or perhaps earlier kernel versions used an actual label
>instead of a tag here.  Use of a label here may have been necessary
>before the assembler had tag support for instance, in which case the
>.pred.rel would have been necessary.

Yes, the first implementation of LOAD_PHYSICAL used a label
(but not because of lack of assembler support for tags, I
just didn't know about them).

-Tony
