From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 13 Oct 2003 18:17:06 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106606930611851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 13 Oct 2003 12:11:52 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> Well, to my eyes the use of the xtime_lock in do_gettimeofday() looks
  Ian> OK, but I guess what you are saying is that the message is moot --
  Ian> xtime_lock protects everything itc_get_offset() needs, and
  Ian> do_gettimeofday() has a read lock on xtime_lock and so reads the
  Ian> offset again if something was updated underneath it.

You do realize that xtime_lock is NOT a lock at all?  Seqlock is a
scheme for lock-free synchronization.  Readers and writers will run
concurrently and the only guarantee that you get is that if a writer
interfered with a reader, the reader will retry its operation (but of
course, this means that the reader occasionally will be seeing
inconsistent data).

	--david
