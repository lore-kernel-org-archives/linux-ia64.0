From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 Feb 2000 20:06:53 +0000
Subject: Re: [Linux-ia64] booting? or is this list dead? ;-)
Message-Id: <marc-linux-ia64-105590678204922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204916@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204916@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 08 Feb 2000 12:31:50 -0700, Tim Riker <TimR@CalderaSystems.com> said:

  Tim> I was just making suggestions.

As far as CD-RW and DVD read capability goes: I have no idea if it
does.  Not something I can test easily.

  Tim> An the other hand, feel free to rant if helps. ;-)

Yep, it did! ;-)

On a related note: I actually had to hack mkisofs to make it possible to
install an El-Torito image bigger than 2.88MB.  I'm sure I didn't do it
entirely correctly, so this is something that should be looked into.

Also, if you use a recent mkisofs, no hacking will be necessary.
Instead, there is now an option that let's you write "harddisk"-typed
boot images (sorry, I forgot the option name, but you'll find it by
searching for El Torito in the cdrecord man page).  This will take
some fiddling and experimenting to get right, I assume.

	--david


