From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 21:51:43 +0000
Subject: Re: [PATCH] Add EXPORT_SYMBOL for physical_node_map
Message-Id: <16425.21103.351759.488933@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040203185728.GX13322@localhost>
In-Reply-To: <20040203185728.GX13322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 3 Feb 2004 13:57:28 -0500, Martin Hicks <mort@wildopensource.com> said:

  Martin> Can you please include this EXPORT_SYMBOL in the next release.  A few
  Martin> macros that use physical_node_map are used in modules.

I share Christoph's concern but since this code is SGI's and Jesse is
apparently OK with it, I'd have applied it---if only the patch
actually applied.  I think there is some whitespace breakage in your
patch.

	--david
