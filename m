From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Jul 2001 00:19:36 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Jul 2001 10:16:44 +1000, Keith Owens <kaos@melbourne.sgi.com> said:

  Keith> There is no 'official' source for syscall numbers.

Yes, there is: you send me mail, I add the respective numbers to
unistd.h, and that's it.  Anyone who messes with that protocol is on
his/her own.

	--david

PS: Note that syscall numbers are arch specific, so if you're looking
    for a platform-independent process, you're looking for the wrong
    thing.

