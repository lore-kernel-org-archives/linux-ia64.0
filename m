From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 21:18:29 +0000
Subject: Re: [Linux-ia64] Re: libgmp3 problem on IA64
Message-Id: <marc-linux-ia64-105590698805222@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805219@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805219@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Sep 2001 15:47:29 -0500, "Eric Gillespie, Jr." <epg@progeny.com> said:

  Eric> Some co-workers started investigating this today, and found a
  Eric> patch from Red Hat which apparently was not shared with
  Eric> bug-gmp.  Even with the patch gmp still fails 19 out of 21 of
  Eric> its tests, so i'm not sure the patch accomplishes much.

For what it's worth: I just tried gmp-3.1.1-4.src.rpm from the Red Hat
"roswell" beta and it passes all tests.  As far as I can tell, there
are no ia64-specific patches other than the one you mentioned.

	--david

