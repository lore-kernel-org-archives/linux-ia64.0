From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 06 Jan 2001 01:58:55 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590678205892@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 06 Jan 2001 11:51:17 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> Where does it say that a prologue always describes the
  Keith> current state?

The fframe directive describes the "size of the frame".  It's not a
delta.

	--david

