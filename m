From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Jul 2004 18:14:39 +0000
Subject: Re: [PATCH] Updated IA64 audit support
Message-Id: <16622.57487.724904.777454@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407091401.i69E1lUf005545@redrum.boston.redhat.com>
In-Reply-To: <200407091401.i69E1lUf005545@redrum.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Martuccelli <peterm@redhat.com>
Cc: davidm@hpl.hp.com, akpm@osdl.org, faith@redhat.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ray.lanza@hp.com

>>>>> On Fri, 9 Jul 2004 10:01:47 -0400, Peter Martuccelli <peterm@redhat.com> said:

  Peter> I updated the patch to use the IS_IA32_PROCESS() macro, and
  Peter> removed trailing white-space as requested.  Retested with the
  Peter> changes, no issues to report. An updated patch follows.  Let
  Peter> me know if there are any other issues.

  Peter> Please CC me directly with with any follow up posts.

Nice and clean.  All that's missing is a changelog entry and a
"Signed-off-by" trailer.  If you send me that, I'll apply it.

Thanks,

	--david
