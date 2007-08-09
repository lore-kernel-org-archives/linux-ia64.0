From: Roland McGrath <roland@redhat.com>
Date: Thu, 09 Aug 2007 06:44:27 +0000
Subject: Re: need NOTES in vmlinux.lds.S
Message-Id: <20070809064427.ED0CE4D04C4@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
In-Reply-To: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That placement is probably fine (the standard size is 36 bytes, so don't
fret too much about how optimal its location is).  Since ia64 has an
explicit PHDRS, it would be ideal to add there a "note PT_NOTE" and then use:

	NOTES :code :note
	code_continues : { } :code

Instead of the second line you can append :code to the next brace group.
(Without one or the other, the following sections will also be included in
the size of the PT_NOTE segment.)

Adding the PT_NOTE phdr is not essential, but it keeps vmlinux holding to
that standard ELF convention, and it's what the other machines do.


Thanks,
Roland
