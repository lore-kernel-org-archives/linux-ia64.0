From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Mar 2005 19:19:43 +0000
Subject: RE: [patch 2.6.11] __copy_user breaks on unaligned src
Message-Id: <16955.10703.845656.684890@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12404.1111129477@kao2.melbourne.sgi.com>
In-Reply-To: <12404.1111129477@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 18 Mar 2005 09:40:02 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> That reminds me ... someone asked why we don't have the same
  Tony> test for lfetch a few lines further down in
  Tony> ia64_do_page_fault() in the "no_context" case (we only test
  Tony> for speculative access there).

Clearly a bug.  Hopefully, that explains Keith's case as well?

	--david
