From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 16 Apr 2001 22:21:17 +0000
Subject: Re: [Linux-ia64] Page size
Message-Id: <marc-linux-ia64-105590693005411@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005409@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005409@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Apr 2001 12:50:13 -0700, Michael Madore <mmadore@turbolinux.com> said:

  Mike> Someone asked me the followind two questions, and I wanted to
  Mike> verify before I gave an answer:

  Mike> Is page size tunable at run time, and can the page size be
  Mike> determined at run time.

  Mike> I was under the impression that page size was a build time
  Mike> parameter.

Don already answered the question as far as the status quo is
concerned.

As for the future: I'd like to start playing with superpage support
fairly soon (once I get some spare time on my hands... ;-).  With
superpages, physically contiguous regions of memory could be mapped
with a single TLB entry, giving you most of the benefit of (very)
large page sizes.

	--david

