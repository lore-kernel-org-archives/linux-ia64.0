From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 25 Jun 2001 21:14:15 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005761@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 25 Jun 2001 13:37:43 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> Justing Gibbs is implementing 39bit addressing into the
  Martin> aix7xxx driver right now.

That's good to hear.  While this won't be a problem with aix7xxx
anymore, as a general rule, drivers should be conscious not to
oversubscribe the I/O TLB.

	--david

