From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 16 Feb 2002 00:52:10 +0000
Subject: Re: [Linux-ia64] [PATCH] linux/fs/partitions/efi.c error handling
Message-Id: <marc-linux-ia64-105590701905125@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Feb 2002 18:46:14 -0600, John Hesterberg <jh@sgi.com> said:

  John> So the key to getting things applied to keep sending the exact
  John> same message over and over and over?

  John> :-)

Actually, I saw Alex's mail only once.  If you use procmail, I highly
recommend adding the following rule near the top of your .procmailrc:

# suppress duplicate mails (e.g., mail sent to multiple mailing lists)
:0 Wh: msgid.lock
| formail -D 32768 mail/msgid.cache

This keeps off all those annoying replicants when cc'd both explicitly
and on mailing-lists.

	--david

