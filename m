From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Sep 2000 21:45:49 +0000
Subject: Re: [Linux-ia64] [PATCH] duplicate #define's in arch/ia64/kernel/minstate.h??
Message-Id: <marc-linux-ia64-105590678205460@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205442@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205442@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 01 Sep 2000 17:00:36 -0400, "Pat O'Rourke" <orourke@mclinux.com> said:

  Pat> It seems that the definition of STOPS, SAVE_MIN_WITH_COVER,
  Pat> SAVE_MIN_WITH_COVER_R19 and SAVE_MIN are duplicated at the end
  Pat> of arch/ia64/kernel/minstate.h.  Is this a typo, or am I
  Pat> missing something?

Typo.  Thanks for catching it.

	--david

